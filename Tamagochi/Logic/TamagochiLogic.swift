//
//  TamagochiObject.swift
//  Tamagochi
//
//  Created by Systems
//

import Foundation

// struct, that manages logic of the tamagochi
struct TamagochiLogic {
    
    // MARK: - Properties
    
    var currentImageData: Data {
        currentTamagochi.imagesData[previewData.pixelPalAction]?[previewData.currentAnimalIndex] ?? Data()
    }
    
    var endedPlayingWithBall: Bool {
        numberOfBallBounces == numberOfBallBouncesMax
    }
    
    private(set) var currentTamagochi: TamagochiObject
    private(set) var currentInteraction = TamagochiInteractions.none
    private(set) var offsetForObject = CGPoint(x: 0, y: 0)
    private(set) var offsetOfWand = CGSize.zero
    private(set) var rotationOfBall = 0.0
    private(set) var previewData = PreviewData(pixelPalAction: .run, images: [], onlyX: true)
    private(set) var numberOfBallBounces = 0
    private(set) var chosenFood = Food.apple
    private(set) var eatedHalf = false
    
    private var numberOfBallBouncesMax = 1
    
    // MARK: - Inits
    
    init(currentTamagochi: TamagochiObject = TamagochiObject(id: -1, imagesData: [:], normalImageData: Data(), lieImageData: Data(), sitImageData: Data(), weight: 0.0, startName: .luna, health: TamagochiObjectConstants.defaultHealth)) {
        self.currentTamagochi = currentTamagochi
    }
    
    init(from coreDataObject: TamagochiLogicEnt) {
        if let currentTamagochi = coreDataObject.currentTamagochi {
            self.currentTamagochi = TamagochiObject(from: currentTamagochi)
        } else {
            self.currentTamagochi = TamagochiObject(id: -1, imagesData: [:], normalImageData: Data(), lieImageData: Data(), sitImageData: Data(), weight: 0.0, startName: .luna, health: TamagochiObjectConstants.defaultHealth)
        }
        let startAction = PixelPalAction.allCases.randomElement() ?? .run
        if let imagesData = currentTamagochi.imagesData[startAction] {
            previewData.updateState(with: startAction, and: imagesData)
        }
    }
    
    // MARK: - Methods
    
    mutating func toggleEatedHalf() {
        eatedHalf.toggle()
    }
    
    mutating func updateCurrentTamagochi(with newValue: TamagochiObject) {
        self.currentTamagochi = newValue
        let coreDataHelper = CoreDataHelper.getCoreData()
        if let name = coreDataHelper.getName(for: newValue.id) {
            self.updateName(with: name)
        }
        let scrolledEogetherValue = coreDataHelper.getScrolledEogether(for: newValue.id)
        self.currentTamagochi.updateScrolledEogether(from: scrolledEogetherValue)
        let savedHealth = coreDataHelper.getHealth(for: newValue.id)
        self.currentTamagochi.setHealth(savedHealth)
        let lastTimeFed = coreDataHelper.getLastTimeFed(for: newValue.id)
        self.currentTamagochi.updateLastTimeFed(with: lastTimeFed)
        let lastTimePlayed = coreDataHelper.getLastTimePlayed(for: newValue.id)
        self.currentTamagochi.updateLastTimePlayed(with: lastTimePlayed)
    }
    
    mutating func updateName(with newValue: String) {
        currentTamagochi.updateName(with: newValue)
        CoreDataHelper.getCoreData().updateName(id: currentTamagochi.id, newName: newValue)
    }
    
    mutating func togglePlayingWithWand() {
        currentInteraction = currentInteraction == .none ? .wand : .none
        if currentInteraction == .wand {
            if Date.now.minutes(from: currentTamagochi.lastTimePlayed) > 5 {
                addHealth()
                currentTamagochi.updateLastTimePlayed(with: .now)
            }
        }
    }
    
    mutating func togglePlayingWithBall() {
        currentInteraction = currentInteraction == .none ? .ball : .none
        if currentInteraction == .ball {
            if Date.now.minutes(from: currentTamagochi.lastTimePlayed) > 5 {
                addHealth()
                currentTamagochi.updateLastTimePlayed(with: .now)
            }
            numberOfBallBounces = 0
            numberOfBallBouncesMax = Int.random(in: 5...15)
            offsetForObject.x = CGFloat.random(in: previewData.minValues.x + 3...previewData.maxValues.x - 3)
        } else {
            updateAction(with: .sleep)
        }
    }
    
    mutating func updateYOffsetOfObject(with newValue: CGFloat) {
        offsetForObject.y = newValue
    }
    
    mutating func updateXOffsetOfBall(toTheRight: Bool = false) {
        if toTheRight {
            if offsetForObject.x < previewData.maxValues.x - 13 {
                offsetForObject.x = CGFloat.random(in: offsetForObject.x...previewData.maxValues.x)
            } else {
                offsetForObject.x = CGFloat.random(in: previewData.minValues.x...offsetForObject.x - 25)
            }
        } else {
            if offsetForObject.x > previewData.minValues.x + 13 {
                offsetForObject.x = CGFloat.random(in: previewData.minValues.x...offsetForObject.x)
            } else {
                offsetForObject.x = CGFloat.random(in: offsetForObject.x + 25...previewData.maxValues.x)
            }
        }
        let rotationValue = Double.random(in: 50...200)
        addRotation(toTheRight ? rotationValue : -rotationValue)
        if numberOfBallBounces == numberOfBallBouncesMax - 1 {
            offsetForObject.y = 150
        }
        if numberOfBallBounces != numberOfBallBouncesMax {
            numberOfBallBounces += 1
        }
    }
    
    mutating func updateRotationOfBall(with newValue: Double) {
        rotationOfBall = newValue
    }
    
    mutating func addRotation(_ degrees: Double) {
        rotationOfBall += degrees
    }
    
    mutating func updateMaxValuesForAnimation(with newValue: CGPoint) {
        previewData.updateMaxValues(with: newValue)
    }
    
    mutating func updateMinValuesForAnimation(with newValue: CGPoint) {
        previewData.updateMinValues(with: newValue)
    }
    
    mutating func animate() {
        previewData.updateCurrentAnimalIndex()
        switch previewData.pixelPalAction {
        case .crouch, .sleep:
            break
        case .run, .chill:
            previewData.updateXOffset()
            if currentInteraction == .wand {
                currentTamagochi.addToScrolledEogether(0.025)
            }
        }
    }
    
    mutating func updateAction(with newValue: PixelPalAction? = nil) {
        let action = newValue ?? PixelPalAction.allCases.randomElement() ?? .run
        if let imagesData = currentTamagochi.imagesData[action] {
            previewData.updateState(with: action, and: imagesData)
        }
    }
    
    mutating func updateReverseXInAnimation(with newValue: Bool) {
        previewData.updateReverseX(with: newValue)
    }
    
    mutating func updateOffsetOfWand(with newValue: CGSize) {
        offsetOfWand = newValue
    }
    
    mutating func toggleFeedWith(food: Food) {
        currentInteraction = currentInteraction == .none ? .feeding : .none
        if currentInteraction == .feeding {
            addHealth()
            currentTamagochi.updateLastTimePlayed(with: .now)
            currentTamagochi.updateLastTimeFed(with: .now)
            chosenFood = food
            offsetForObject.x = CGFloat.random(in: previewData.minValues.x + 3...previewData.maxValues.x - 3)
        } else {
            currentTamagochi.addWeight(0.1)
            updateAction(with: .sleep)
        }
    }
    
    mutating func addHealth() {
        currentTamagochi.addHealth(1)
    }
    
    mutating func removeHealth() {
        currentTamagochi.addHealth(-1)
    }
    
    mutating func updateLastTimeFed(with newValue: Date) {
        print("Обновление времени последнего кормления для кота с id \(currentTamagochi.id) на \(newValue)")
        currentTamagochi.updateLastTimeFed(with: newValue)
        CoreDataHelper.getCoreData().updateLastTimeFed(id: currentTamagochi.id, newValue: newValue)
    }
}

