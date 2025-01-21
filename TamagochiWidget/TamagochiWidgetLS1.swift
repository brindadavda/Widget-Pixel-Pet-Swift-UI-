//
//  TamagochiWidgetLS.swift
//  Tamagochi
//
//  Created by Systems
//

import WidgetKit
import SwiftUI

struct ProviderLS: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> WidgetEntryLS {
        return WidgetEntryLS(date: .now, animalImage: getPreviewAnimals(from: ConfigurationLSIntent()).first ?? UIImage(), currentOffset: .zero, showBackground: false, isReversed: false, bgHeight: context.displaySize.height)
    }

    func getSnapshot(for configuration: ConfigurationLSIntent, in context: Context, completion: @escaping (WidgetEntryLS) -> ()) {
        let entry = WidgetEntryLS(date: .now, animalImage: getPreviewAnimals(from: ConfigurationLSIntent()).first ?? UIImage(), currentOffset: 0, showBackground: configuration.showBackground == 1 ? true : false, isReversed: false, bgHeight: context.displaySize.height)
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationLSIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [WidgetEntryLS] = []
        var index = 0
        var currentOffset: CGFloat = 0
        var isReversed = false
        let previewAnimals = getPreviewAnimals(from: configuration)
        let currentDate = Date()
        for secondOffset in 0..<180 {
            let entryDate = Calendar.current.date(byAdding: .second, value: secondOffset, to: currentDate)!
            let entry = WidgetEntryLS(date: entryDate, animalImage: previewAnimals[index], currentOffset: currentOffset, showBackground: configuration.showBackground == 1 ? true : false, isReversed: isReversed, bgHeight: context.displaySize.height)
            entries.append(entry)
            if index != previewAnimals.count - 1 {
                index += 1
            }
            else {
                index = 0
            }
            if configuration.actionType.pixelPalAction == .run || configuration.actionType.pixelPalAction == .chill {
                if !isReversed {
                    if currentOffset < context.displaySize.width / 2 {
                        currentOffset += 5
                    } else {
                        isReversed = true
                    }
                } else {
                    if currentOffset > -(context.displaySize.width / 2) {
                        currentOffset -= 5
                    } else {
                        isReversed = false
                    }
                }
            }
        }
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func getPreviewAnimals(from config: ConfigurationLSIntent) -> [UIImage] {
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
    
}

struct WidgetEntryLS: TimelineEntry {
    
    let date: Date
    let animalImage: UIImage
    let currentOffset: CGFloat
    let showBackground: Bool
    let isReversed: Bool
    let bgHeight: CGFloat
    
}

struct TamagochiWidgetEntryViewLS : View {
    var entry: ProviderLS.Entry

    var body: some View {
        HStack {
            Spacer()
            Image(uiImage: entry.animalImage)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .scaleEffect(x: entry.isReversed ? -1 : 1, y: 1)
                .offset(x: entry.currentOffset)
            Spacer()
        }
        .background {
            if entry.showBackground {
                Color.clear
                    .background(.ultraThinMaterial)
                    .cornerRadius(entry.bgHeight * 0.9 * 0.5)
                    .frame(height: entry.bgHeight * 0.9)
            }
        }
        .widgetBackground(Color.clear)
    }
    
}

struct TamagochiWidgetLS: Widget {
    let kind: String = "TamagochiWidgetLS"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationLSIntent.self, provider: ProviderLS()) { entry in
            TamagochiWidgetEntryViewLS(entry: entry)
        }
        .configurationDisplayName("Tamagochi Widget")
        .description("Show your cute friends on your Lock Screen!")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular])
    }
}

//struct TamagochiWidgetLS_Previews: PreviewProvider {
//    
//    static var previews: some View {
//        
//        TamagochiWidgetEntryViewLS(entry: WidgetEntryLS(date: .now, animalImage: UIImage(), currentOffset: .zero, showBackground: false, isReversed: false, bgHeight: 50))
//            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
//    }
//    
//}

