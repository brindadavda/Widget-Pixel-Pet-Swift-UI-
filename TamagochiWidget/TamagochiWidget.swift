//
//  TamagochiWidget.swift
//  TamagochiWidget
//
//  Created by Systems
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    
    private let settingsViewModel = SmartPetSettingsViewModel(isForWidget: true)
    
    func placeholder(in context: Context) -> WidgetEntry {
        let config = ConfigurationIntent()
        let widgetType = WidgetType_TamagochiVVV.calendar
        let widgetsViewModel = WidgetsViewModel(isForWidget: true, widgetType: widgetType)
        let bgImage = getBGImage(from: config)
        widgetsViewModel.updateIsBigPal(with: config.bigPal ?? 0 == 0 ? false : true)
        return WidgetEntry(magicClockGrid: nil, widgetsViewModel: widgetsViewModel, type: widgetType, previewAnimals: [getPreviewAnimals(from: config)[0]], bgImage: bgImage)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (WidgetEntry) -> ()) {
        Task {
            let bgImage = getBGImage(from: configuration)
            let widgetType = configuration.infoBackground?.widgetType ?? .battery
            let widgetsViewModel = WidgetsViewModel(isForWidget: true, widgetType: widgetType)
            widgetsViewModel.updateIsBigPal(with: configuration.bigPal ?? 0 == 0 ? false : true)
            let entry = await WidgetEntry(magicClockGrid: getGrid(with: context.displaySize), widgetsViewModel: widgetsViewModel, type: widgetType, previewAnimals: [getPreviewAnimals(from: configuration)[0]], bgImage: bgImage)
            completion(entry)
        }
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            var entries: [WidgetEntry] = []
            let type = configuration.infoBackground?.widgetType ?? .battery
            var quote: Quote?
            if type == .quoteSmall || type == .quoteBig {
                quote = Quote.getQuotes().randomElement()
            }
            let maxValuesForOffset = CGPoint(x: context.displaySize.width / 2, y: context.displaySize.height / 2)
            let minValuesForOffset = CGPoint(x: -context.displaySize.width / 2, y: -context.displaySize.height / 2)
            var index = 0
            var isXReversed = false
            var isYReversed = false
            let randomX = Double.random(in: minValuesForOffset.x + 10...maxValuesForOffset.x - 10)
            let randomY = Double.random(in: minValuesForOffset.y + 10...maxValuesForOffset.y - 10)
            var currentOffset = CGPoint(x: randomX, y: randomY)
            let currentDate = Date()
            var startDate = Date.now
            var magicClockGrid : MagicClockGrid?
            let previewAnimals = getPreviewAnimals(from: configuration)
            let bgImage = getBGImage(from: configuration)
            let tempData = try? await settingsViewModel.getWeather()
            if type == .magicClock {
                magicClockGrid = await getGrid(with: context.displaySize, and: startDate)
            }
            for secondOffset in 0..<180 {
                let entryDate = Calendar.current.date(byAdding: .second, value: secondOffset, to: currentDate)!
                let widgetsViewModel = WidgetsViewModel(isForWidget: true, widgetType: type, action: configuration.actionType.pixelPalAction)
                widgetsViewModel.updateIsBigPal(with: configuration.bigPal ?? 0 == 0 ? false : true)
                widgetsViewModel.selectedBGStyle = configuration.background.bgStyle
                widgetsViewModel.selectedTextStyle = configuration.fontStyle.textStyle
                widgetsViewModel.updateColor(with: configuration.background.color)
                widgetsViewModel.updateHexString(with: configuration.hexCode ?? "")
                widgetsViewModel.updateTextColor(with: configuration.textColor.color)
                if type == .quoteSmall || type == .quoteBig {
                    if let quote {
                        widgetsViewModel.updateQuote(with: quote)
                    }
                }
                if type == .magicClock && !startDate.isSameMinutes(with: entryDate) {
                    magicClockGrid = await getGrid(with: context.displaySize, and: entryDate)
                    startDate = entryDate
                }
                widgetsViewModel.updateMaxValueForAnimation(of: type, with: maxValuesForOffset)
                widgetsViewModel.updateMinValueForAnimation(of: type, with: minValuesForOffset)
                widgetsViewModel.updateDate(with: entryDate)
                widgetsViewModel.updateOffset(of: type, from: currentOffset, isXReversed: isXReversed, isYReversed: isYReversed)
                if let tempData, !tempData.isEmpty {
                    widgetsViewModel.updateTempData(with: tempData)
                }
                let entry = WidgetEntry(magicClockGrid: magicClockGrid, widgetsViewModel: widgetsViewModel, type: type, previewAnimals: [previewAnimals[index]], bgImage: bgImage)
                entries.append(entry)
                if index != previewAnimals.count - 1 {
                    index += 1
                }
                else {
                    index = 0
                }
                currentOffset = widgetsViewModel.previewData[type]?.offsetForAnimation ?? .zero
                isXReversed = widgetsViewModel.previewData[type]?.isXReversed ?? false
                isYReversed = widgetsViewModel.previewData[type]?.isYReversed ?? false
            }
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
    
    private func getPreviewAnimals(from config: ConfigurationIntent) -> [UIImage] {
        let cat = config.pixelPal.cat
        let action = config.actionType.pixelPalAction
        let tamagochiImagesData = CoreDataHelper.getCoreData(isForWidget: true).getTamagochiImages(with: cat, and: action)
        var result = [UIImage]()
        for imageData in tamagochiImagesData {
            if let image = UIImage(data: imageData) {
                result.append(image)
            }
        }
        return result
    }
    
    private func getBGImage(from config: ConfigurationIntent) -> UIImage {
        let photoID = config.background.photoID
        var imageData: Data?
        if photoID != -1 {
            imageData = settingsViewModel.getWidgetBGForWidget(with: photoID)
        } else if config.background == .transparent {
            imageData = settingsViewModel.getTransparentBG()
        } else if config.background == .customPhoto {
            imageData = settingsViewModel.getUserBGForWidget(with: config.photo?.identifier ?? "")
        }
        if let imageData {
            if let image = UIImage(data: imageData) {
                return image
            }
        }
        return UIImage()
    }
    
    private func getGrid(with size: CGSize, and date: Date = .now) async -> MagicClockGrid {
        let minSide = min(size.width, size.height)
        let magicClockGrid = MagicClockGrid()
        await magicClockGrid.updateGridAsync(with: CGSize(width: size.width, height: size.height), and: CGSize(width: minSide / 12, height: minSide / 12), date: date)
        return magicClockGrid
    }
    
}

struct WidgetEntry: TimelineEntry {
    
    var date: Date {
        widgetsViewModel.widgetData.date
    }
    
    let magicClockGrid: MagicClockGrid?
    let widgetsViewModel: WidgetsViewModel
    let type: WidgetType_TamagochiVVV
    let previewAnimals: [UIImage]
    let bgImage: UIImage
    
}

struct TamagochiWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        makeWidgetView(for: entry.type, with: entry.previewAnimals, and: entry.bgImage, magicClockGrid: entry.magicClockGrid)
            .environmentObject(entry.widgetsViewModel)
            .widgetBackground(entry.widgetsViewModel.widgetData.bgColor.color)
    }
    
}

struct TamagochiWidget: Widget {
    let kind: String = "TamagochiWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            TamagochiWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Tamagochi Widget")
        .description("Show your cute friends on your Home Screen!")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
        .containerBackgroundRemovable(false)
    }
}

struct TamagochiWidget_Previews: PreviewProvider {
    
    static var previews: some View {
        
        TamagochiWidgetEntryView(entry: WidgetEntry(magicClockGrid: nil, widgetsViewModel: WidgetsViewModel(isForWidget: true, widgetType: .calendar, action: .run), type: .calendar, previewAnimals: [], bgImage: UIImage()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
    
}
