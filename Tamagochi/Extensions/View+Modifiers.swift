//
//  View+Modifiers.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI

struct RectangleBackground: ViewModifier {
    
    let strokeColor: Color
    let backgroundColor: Color
    let shouldApply: Bool
    let cornerRadius: Double
    
    func body(content: Content) -> some View {
        if shouldApply {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .inset(by: 0.5)
                    .stroke(strokeColor, lineWidth : 1)
                    .background(backgroundColor)
                content
            }
            .cornerRadius(cornerRadius)
        }
        else {
            content
        }
    }
    
}

struct WidgetModifier<T: View>: ViewModifier {
    
    let minSide: Double
    let backgroundView: T
    let foregroundColor: Color
    
    func body(content: Content) -> some View {
        content
            .minimumScaleFactor(0.2)
            .lineLimit(1)
            .multilineTextAlignment(.center)
            .foregroundColor(foregroundColor)
            .background {
                backgroundView
            }
            .cornerRadius(minSide * 0.1)
            .drawingGroup()
    }
    
}

typealias View_TamagochiVVV = View

extension View_TamagochiVVV {
    
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOS 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
    
    func onStatusBarTap(with geo: GeometryProxy, and onTap: @escaping () -> ()) -> some View {
        self.overlay {
            StatusBarTabDetector(onTap: onTap)
                .offset(y: UIScreen.main.bounds.height)
                .frame(width: geo.size.width * 0.33)
        }
    }
    
    func makeInstructionView(with title: String, and description: String, minSide: Double) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(
                        Font.custom("DM Sans", size: UIDevice.current.userInterfaceIdiom == .phone ? 18 : 24)
                            .weight(.bold)
                    )
                    .padding(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))
                Text(description)
                    .font(
                        Font.custom("DM Sans", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 20)
                    )
                    .padding(EdgeInsets(top: 20, leading: 16, bottom: 16, trailing: 16))
            }
            Spacer()
        }
        .foregroundColor(.white)
        .multilineTextAlignment(.leading)
        .lineSpacing(10)
        .minimumScaleFactor(0.2)
        .rectangleBackground(with: Color(red: 0, green: 0.27, blue: 1), backgroundColor: Color(red: 0, green: 0.27, blue: 1).opacity(0.2), cornerRadius: 12)
    }
    
    func makeLineView(needPadding: Bool = true) -> some View {
        Rectangle()
            .foregroundColor(.clear)
            .frame(height: 1)
            .background(Color(red: 0.45, green: 0.56, blue: 0.86))
            .padding(needPadding ? EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20) : EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
    
    func rectangleBackground(with strokeColor: Color, backgroundColor: Color, cornerRadius: Double, shouldApply: Bool = true) -> some View {
        self.modifier(RectangleBackground(strokeColor: strokeColor, backgroundColor: backgroundColor, shouldApply: shouldApply, cornerRadius: cornerRadius))
    }
    
    func widgetModifier(with minSide: Double, and backgroundView: some View, foregroundColor: Color) -> some View {
        self.modifier(WidgetModifier(minSide: minSide, backgroundView: backgroundView, foregroundColor: foregroundColor))
    }
    
    func getAnimalImage(with geo: GeometryProxy, and uiImage: UIImage, isBig: Bool = false) -> some View {
        Image(uiImage: uiImage)
            .resizable()
            .scaledToFit()
            .frame(height: isBig ? geo.size.height / 3 : geo.size.height / 6)
            .zIndex(1)
    }
    
    @ViewBuilder
    func makeWidgetView(for widgetType: WidgetType_TamagochiVVV, with animalImages: [UIImage], and bgImage: UIImage, magicClockGrid: MagicClockGrid? = nil) -> some View {
        switch widgetType {
        case .clockText, .dateNumber:
            ClockText(type: widgetType, previewAnimals: animalImages, bgImage: bgImage)
        case .clockTextAndDate:
            ClockTextAndDate(previewAnimals: animalImages, bgImage: bgImage)
        case .quoteSmall, .quoteBig:
            QuoteView(type: widgetType, previewAnimals: animalImages, bgImage: bgImage)
        case .battery:
            BatteryWidgetView(previewAnimals: animalImages, bgImage: bgImage)
        case .calendar:
            CalendarView_TamagochiVVV(previewAnimals: animalImages, bgImage: bgImage)
        case .goodDay:
            GoodDayView(previewAnimals: animalImages, bgImage: bgImage)
        case .info:
            InfoWidgetView(previewAnimals: animalImages, bgImage: bgImage)
        case .weatherVertical:
            WeatherTextView(type: widgetType, previewAnimals: animalImages, bgImage: bgImage)
        case .weatherHorizontal:
            WeatherTextView(type: widgetType, previewAnimals: animalImages, bgImage: bgImage)
        case .multipleWeatherHorizontal, .multipleWeatherVertical, .multipleWeatherStyled:
            WeatherMultipleView(type: widgetType, previewAnimals: animalImages, bgImage: bgImage)
        case .event:
            EventView(previewAnimals: animalImages, bgImage: bgImage)
        case .magicClock:
            MagicClockView(previewAnimals: animalImages, bgImage: bgImage, magicClockGridForWidget: magicClockGrid)
        case .clock, .clockDetail:
            ClockWidgetView(type: widgetType, previewAnimals: animalImages, bgImage: bgImage)
        }
    }
    
}
