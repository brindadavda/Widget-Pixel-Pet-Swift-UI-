//
//  WidgetsViewModel.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI
import Combine

// view model for widgets
class WidgetsViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @AppStorage("currentEvent", store: UserDefaults(suiteName: AppConstants.groupName.rawValue)) var currentEvent = "Taylor Swift Concert"
    @AppStorage("currentEventDate", store: UserDefaults(suiteName: AppConstants.groupName.rawValue)) var currentEventDate = Date.now
    
    @Published private(set) var currentAnimalIndex = 0
    @Published private(set) var widgetData = WidgetData()
    @Published private(set) var previewData = [WidgetType_TamagochiVVV: PreviewData]()
    
    private(set) var quotes = [WidgetType_TamagochiVVV: Quote]()
    private(set) var temperaturesData = [Temperature]()
    private(set) var isForWidget = false
    
    private var allTamagochies = [TamagochiObject]()
    private var subscribers = Set<AnyCancellable>()
    
    private let widgetAction: PixelPalAction
    private let coreDataHelper = CoreDataHelper.getCoreData()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var selectedSize: WidgetSize = .small {
        didSet {
            widgetData.updateSize(with: selectedSize)
        }
    }
    
    var selectedTextStyle: TextStyle = .normal {
        didSet {
            widgetData.updateTextStyle(with: selectedTextStyle)
        }
    }
    
    var selectedBGStyle: BGStyle = .transparent {
        didSet {
            widgetData.updateBGStyle(with: selectedBGStyle)
        }
    }
    
    var availableStorage: String {
        UIDevice.current.systemFreeSize
    }
    
    // MARK: - Inits
    
    init(isForWidget: Bool = false, widgetType: WidgetType_TamagochiVVV? = nil, action: PixelPalAction = .run) {
        self.isForWidget = isForWidget
        self.widgetAction = action
        coreDataHelper.shouldSave = !isForWidget
        if !isForWidget {
            allTamagochies = coreDataHelper.getTamagochies()
            generateQuotes()
        }
        else {
            if let widgetType {
                previewData[widgetType] = PreviewData(pixelPalAction: action, images: [])
            }
        }
        getTemperatureData()
        if !isForWidget {
            setupTimer()
        }
    }
    
    // MARK: - Methods
    
    func shouldApplyOffset() -> Bool {
        !(isForWidget && (widgetAction == .run || widgetAction == .chill))
    }
    
    private func setupTimer() {
        
         
        
        timer
            .sink(receiveValue: { [weak self] value in
                guard let self else { return }
                for (key, _) in previewData {
                    previewData[key]?.updateCurrentAnimalIndex()
                }
                widgetData.updateDate(with: .now)
                for (key, _) in previewData {
                    if let pixelPalAction = previewData[key]?.pixelPalAction {
                        switch pixelPalAction {
                        case .crouch, .sleep:
                            break
                        case .run, .chill:
                            previewData[key]?.updateXOffset()
                        }
                    }
                }
            })
            .store(in: &subscribers)
    }
    
    private func generateQuotes() {
        for widgetType in [WidgetType_TamagochiVVV.quoteBig, WidgetType_TamagochiVVV.quoteSmall] {
            quotes[widgetType] = Quote.getQuotes().randomElement() ?? Quote(text: "bla", author: "bla")
        }
    }
    
    func generatePreviewData() {
        previewData = [:]
        for widget in WidgetType_TamagochiVVV.allCases {
            let randomTamagochi = allTamagochies.randomElement() ?? allTamagochies.first
            let randomPixelPalAction = PixelPalAction.allCases.randomElement() ?? .chill
            if let randomTamagochi, let imagesData = randomTamagochi.imagesData[randomPixelPalAction] {
                previewData[widget] = PreviewData(pixelPalAction: randomPixelPalAction, images: imagesData)
            }
        }
    }
    
    private func getTemperatureData() {
        for i in 1...4 {
            temperaturesData.append(Temperature(date: .now, symbolName: "sun.max.fill", value: 22 + i))
        }
    }
    
    func getCurrentWeatherData() -> Temperature {
        if !temperaturesData.isEmpty {
            return temperaturesData.first!
        }
        else {
            return Temperature(date: .now, symbolName: "sun.max.fill", value: 22)
        }
    }
    
    func getOffsetForAnimation(of widgetType: WidgetType_TamagochiVVV) -> CGPoint {
        if let pixelPalAction = previewData[widgetType]?.pixelPalAction {
            switch pixelPalAction {
            case .crouch, .sleep:
                return .zero
            case .run, .chill:
                return previewData[widgetType]?.offsetForAnimation ?? .zero
            }
        }
        return .zero
    }
    
    func getAnimationStatus(of widgetType: WidgetType_TamagochiVVV) -> Bool {
        previewData[widgetType]?.isXReversed ?? false
    }
    
    // MARK: - Intents
    
    func updateHexString(with newValue: String) {
        widgetData.updateHexString(with: newValue)
    }
    
    func updateIsBigPal(with newValue: Bool) {
        widgetData.updateIsBigPal(with: newValue)
    }
    
    func updateTempData(with newValue: [Temperature]) {
        temperaturesData = newValue
    }
    
    func updateQuote(with newValue: Quote) {
        for widgetType in [WidgetType_TamagochiVVV.quoteBig, WidgetType_TamagochiVVV.quoteSmall] {
            quotes[widgetType] = newValue
        }
    }
    
    func updateMaxValueForAnimation(of widgetType: WidgetType_TamagochiVVV, with newValue: CGPoint) {
        previewData[widgetType]?.updateMaxValues(with: newValue)
    }
    
    func updateMinValueForAnimation(of widgetType: WidgetType_TamagochiVVV, with newValue: CGPoint) {
        previewData[widgetType]?.updateMinValues(with: newValue)
    }
    
    func updateColor(with newValue: AvailableColors? = nil) {
        if let newValue {
            widgetData.updateBGColor(with: newValue)
        } else {
            var randomColor = AvailableColors.allCases.randomElement() ?? .aquaMint
            while randomColor == widgetData.bgColor || randomColor == .black || randomColor == .white {
                randomColor = AvailableColors.allCases.randomElement() ?? .aquaMint
            }
            widgetData.updateBGColor(with: randomColor)
        }
    }
    
    func updateTextColor(with newValue: AvailableColors) {
        widgetData.updateTextColor(with: newValue)
    }
    
    func updateCurrentEvent(with newDate: Date, and value: String) {
        currentEvent = value
        currentEventDate = newDate
    }
    
    func updateDate(with newValue: Date) {
        widgetData.updateDate(with: newValue)
    }
    
    func updateOffset(of widgetType: WidgetType_TamagochiVVV, from currentOffset: CGPoint, isXReversed: Bool, isYReversed: Bool) {
        previewData[widgetType]?.updateReverseX(with: isXReversed)
        previewData[widgetType]?.updateReverseY(with: isYReversed)
        previewData[widgetType]?.updateOffset(with: currentOffset)
        previewData[widgetType]?.updateXOffset()
    }
}
