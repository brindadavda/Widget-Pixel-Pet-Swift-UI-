//
//  TamagochiViewModel.swift
//  Tamagochi
//
//  Created by Systems
//

import Combine
import SwiftUI
import Foundation

// view model for tamagochi
class TamagochiViewModel: ObservableObject {
    
    // MARK: - Properties
    
    private let coreDataHelper = CoreDataHelper.getCoreData()
    
    @Published private(set) var tamagochiLogic = TamagochiLogic()
    @Published private(set) var allTamagochies = [TamagochiObject]()
    
    var lastTimeFed: Date {
        tamagochiLogic.currentTamagochi.lastTimeFed
    }
    
    var eatedHalf: Bool {
        tamagochiLogic.eatedHalf
    }
    
    var currentInteraction: TamagochiInteractions {
        tamagochiLogic.currentInteraction
    }
    
    var currentFood: Food {
        tamagochiLogic.chosenFood
    }
    
    var offsetOfWand: CGSize {
        tamagochiLogic.offsetOfWand
    }
    
    var endedPlayingWithBall: Bool {
        tamagochiLogic.endedPlayingWithBall
    }
    
    var offsetForObject: CGPoint {
        tamagochiLogic.offsetForObject
    }
    
    var rotationOfBall: Double {
        tamagochiLogic.rotationOfBall
    }
    
    var currentImageData: Data {
        tamagochiLogic.currentImageData
    }
    
    var currentAction: PixelPalAction {
        tamagochiLogic.previewData.pixelPalAction
    }
    
    var offsetForAnimation: CGPoint {
        tamagochiLogic.previewData.offsetForAnimation
    }
    
    var isXReversed: Bool {
        tamagochiLogic.previewData.isXReversed
    }
    
    var maxX: CGFloat {
        tamagochiLogic.previewData.maxValues.x
    }
    
    private var subscribers = Set<AnyCancellable>()
    
    private let healthTimer = Timer.publish(every: 480, on: .main, in: .common).autoconnect()
    private let tamagochiTimerFast = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
    private let tamagochiTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    private let tamagochiActionTimer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    
    // MARK: - Inits
    
    init(isForWidget: Bool = false) {
        coreDataHelper.shouldSave = !isForWidget
        if !isForWidget {
            allTamagochies = coreDataHelper.getTamagochies()
            if allTamagochies.isEmpty {
                setTamagochies()
            }
        }
        if !isForWidget {
            setupMainPublishers()
        }
        tamagochiLogic = coreDataHelper.getLogic()
        if !isForWidget {
            setupHealthTimer()
            setupAnimTimers()
            setupTamagochiActionTimer()
        }
    }
    
    // MARK: - Methods
    
    private func setupTamagochiActionTimer() {
        
        self.tamagochiActionTimer
            .sink(receiveValue: { [weak self] value in
                guard let self else { return }
                if currentInteraction == .none {
                    self.tamagochiLogic.updateAction()
                }
            })
            .store(in: &subscribers)
    }
    
    private func setupAnimTimers() {
        self.tamagochiTimerFast
            .sink(receiveValue: { [weak self] value in
                guard let self else { return }
                switch tamagochiLogic.previewData.pixelPalAction {
                case .crouch, .run, .chill:
                    self.animateCat()
                case .sleep:
                    break
                }
            })
            .store(in: &subscribers)
        self.tamagochiTimer
            .sink(receiveValue: { [weak self] value in
                guard let self else { return }
                switch tamagochiLogic.previewData.pixelPalAction {
                case .crouch, .run, .chill:
                    break
                case .sleep:
                    self.animateCat()
                }
            })
            .store(in: &subscribers)
    }
    
    private func setupMainPublishers() {
        self.$tamagochiLogic
            .sink { [weak self] newValue in
                guard let self else { return }
                self.coreDataHelper.updateLogic(with: newValue)
            }
            .store(in: &subscribers)
        self.$allTamagochies
            .sink { [weak self] newValue in
                guard let self else { return }
                self.coreDataHelper.addTamagochies(newValue)
            }
            .store(in: &subscribers)
    }
    
    private func setupHealthTimer() {
        self.healthTimer
            .sink(receiveValue: { [weak self] value in
                guard let self else { return }
                self.tamagochiLogic.removeHealth()
            })
            .store(in: &subscribers)
    }
    
    private func animateCat() {
        switch currentInteraction {
        case .none:
            tamagochiLogic.animate()
        case .ball, .feeding:
            playingWithBallOrFeedingAnim()
        case .wand:
            playingWithWandAnim()
        }
    }
    
    private func playingWithBallOrFeedingAnim() {
        let distance = offsetForObject.x - offsetForAnimation.x
        let toTheRight = distance > 0
        if abs(offsetForObject.x - offsetForAnimation.x) <= 20 {
            if currentInteraction == .ball {
                tamagochiLogic.updateXOffsetOfBall(toTheRight: endedPlayingWithBall ? !toTheRight : toTheRight)
            }
            else if currentInteraction == .feeding {
                if tamagochiLogic.previewData.pixelPalAction != .crouch {
                    tamagochiLogic.updateAction(with: .crouch)
                    let foodTimer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
                    foodTimer
                        .sink(receiveValue: { [weak self] value in
                            guard let self else { return }
                            if !eatedHalf {
                                tamagochiLogic.toggleEatedHalf()
                            }
                            else {
                                tamagochiLogic.toggleEatedHalf()
                                foodTimer.upstream.connect().cancel()
                            }
                        })
                        .store(in: &subscribers)
                }
            }
        }
        tamagochiLogic.updateReverseXInAnimation(with: !toTheRight)
        tamagochiLogic.animate()
    }
    
    private func playingWithWandAnim() {
        tamagochiLogic.animate()
        let distance = offsetOfWand.width - offsetForAnimation.x
        let toTheRight = distance > 0
        let condition1 = offsetForAnimation.x == tamagochiLogic.previewData.maxValues.x && toTheRight
        let condition2 = offsetForAnimation.x == tamagochiLogic.previewData.minValues.x && !toTheRight
        if abs(offsetOfWand.width - offsetForAnimation.x) <= 20 || condition1 || condition2 {
            if tamagochiLogic.previewData.pixelPalAction != .crouch {
                tamagochiLogic.updateAction(with: .crouch)
            }
        }
        else if tamagochiLogic.previewData.pixelPalAction != .run {
            tamagochiLogic.updateAction(with: .run)
        }
        tamagochiLogic.updateReverseXInAnimation(with: !toTheRight)
    }
    
    private func setTamagochies() {
        for cat in Cats.allCases {
            var actionsImagesData = [PixelPalAction: [Data]]()
            for action in PixelPalAction.allCases {
                var imagesData = [Data]()
                var range = 1...8
                switch action {
                case .crouch:
                    range = 1...8
                case .run:
                    range = 1...4
                case .sleep:
                    range = 1...2
                case .chill:
                    range = 1...8
                }
                for i in range {
                    if let imageData = UIImage(named: "cat_\(cat.id)_\(action.rawValue)_\(i)")?.pngData() {
                        imagesData.append(imageData)
                    }
                }
                actionsImagesData[action] = imagesData
            }
            let normalImageData = UIImage(named: "cat_\(cat.id)_normal")?.pngData()
            let sitImageData = UIImage(named: "cat_\(cat.id)_sit")?.pngData()
            let lieImageData = UIImage(named: "cat_\(cat.id)_lie")?.pngData()
            if let normalImageData, let sitImageData, let lieImageData {
                var tamagochiObject = TamagochiObject(id: cat.id, imagesData: actionsImagesData, normalImageData: normalImageData, lieImageData: lieImageData, sitImageData: sitImageData, weight: cat.weightInLbs, startName: cat, health: 3)
                tamagochiObject.updateName(with: cat.rawValue.capitalizeFirstLetter())
                allTamagochies.append(tamagochiObject)
            }
        }
    }
    
    private func spawnObject() {
        tamagochiLogic.updateAction(with: .run)
        var yForAnimation: CGFloat = -70
        tamagochiLogic.updateYOffsetOfObject(with: yForAnimation)
        let starterTimer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
        starterTimer
            .sink(receiveValue: { [weak self] value in
                guard let self else { return }
                yForAnimation += 70
                self.tamagochiLogic.updateYOffsetOfObject(with: yForAnimation)
                if self.currentInteraction == .ball {
                    self.tamagochiLogic.addRotation(75)
                }
                starterTimer.upstream.connect().cancel()
            })
            .store(in: &subscribers)
        let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()
        timer
            .sink(receiveValue: { [weak self] value in
                guard let self else { return }
                if yForAnimation == .zero {
                    yForAnimation -= 25
                }
                else {
                    yForAnimation = .zero
                    timer.upstream.connect().cancel()
                }
                self.tamagochiLogic.updateYOffsetOfObject(with: yForAnimation)
                if self.currentInteraction == .ball {
                    self.tamagochiLogic.addRotation(75)
                }
            })
            .store(in: &subscribers)
    }
    
    // MARK: - Intents
    
    func updateSelectedAnimal(with id: Int) {
        if let tamagochi = allTamagochies.first(where: {$0.id == id}) {
            tamagochiLogic.updateCurrentTamagochi(with: tamagochi)
        }
    }
    
    func nextSelectedAnimal(with id: Int) {
        let maxCount = allTamagochies.count - 1
        let indexSelected = allTamagochies.firstIndex(where: { $0.id == id} )
        
        guard let indexSelected else { return }
        
        if indexSelected < maxCount {
            let tamagochi = allTamagochies[indexSelected+1]
            tamagochiLogic.updateCurrentTamagochi(with: tamagochi)
            return
        }
        
        if indexSelected == maxCount,
           let tamagochi = allTamagochies.first {
            tamagochiLogic.updateCurrentTamagochi(with: tamagochi)
        }
    }
    
    func previosSelectedAnimal(with id: Int) {
        let indexSelected = allTamagochies.firstIndex(where: { $0.id == id} )
        
        guard let indexSelected else { return }
        
        if indexSelected > 0 {
            let tamagochi = allTamagochies[indexSelected-1]
            tamagochiLogic.updateCurrentTamagochi(with: tamagochi)
            return
        }
        
        if indexSelected == 0,
           let tamagochi = allTamagochies.last {
            tamagochiLogic.updateCurrentTamagochi(with: tamagochi)
        }
    }
    
    func updateName(with newValue: String) {
        tamagochiLogic.updateName(with: newValue)
    }
    
    func togglePlayingWithWand() {
        tamagochiLogic.togglePlayingWithWand()
        tamagochiLogic.updateAction(with: .sleep)
    }
    
    func togglePlayingWithBall() {
        tamagochiLogic.togglePlayingWithBall()
        if currentInteraction == .ball {
            spawnObject()
        }
    }
    
    func updateMaxValuesForAnimation(with newValue: CGPoint) {
        tamagochiLogic.updateMaxValuesForAnimation(with: newValue)
    }
    
    func updateMinValuesForAnimation(with newValue: CGPoint) {
        tamagochiLogic.updateMinValuesForAnimation(with: newValue)
    }
    
    func updateOffsetOfWand(with newValue: CGSize) {
        tamagochiLogic.updateOffsetOfWand(with: newValue)
    }
    
    func toggleFeedWith(food: Food) {
        tamagochiLogic.toggleFeedWith(food: food)
        if currentInteraction == .feeding {
            spawnObject()
        }
    }
    
}
