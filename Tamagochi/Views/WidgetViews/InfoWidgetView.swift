//
//  InfoWidgetView.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI

struct InfoWidgetView: WidgetView_TamagochiVVV {
    
    // MARK: - Properties
    
    @EnvironmentObject var widgetsViewModel: WidgetsViewModel
    
    @State var minSide: Double = 1.0
    
    let type: WidgetType_TamagochiVVV = .info
    let previewAnimals: [UIImage]
    let bgImage: UIImage
    
    // MARK: - Body
    
    var body: some View {
        makeUI()
    }
    
    // MARK: - UI
    
    private func makeUI() -> some View {
        GeometryReader { geo in
            HStack {
                VStack {
                    getTopView(with: geo)
                    getBottomView(with: geo)
                }
            }
            .minimumScaleFactor(1)
            .overlay {
                HStack {
                    getOverlay(with: geo, and: .zero)
                    if widgetsViewModel.shouldApplyOffset() {
                        Spacer()
                    }
                }
            }
            .onAppear {
                minSide = min(geo.size.width, geo.size.height)
            }
            .onChange(of: geo.size) { newValue in
                minSide = min(newValue.width, newValue.height)
            }
            .font(widgetsViewModel.widgetData.textStyle.getFontWithSize(geo.size.height / 10))
            .frame(maxWidth: geo.size.width, maxHeight: geo.size.height)
            .widgetModifier(with: widgetsViewModel.isForWidget ? 0 : minSide, and: getBackground(with: geo), foregroundColor: widgetsViewModel.widgetData.textColor.color)
        }
    }
    
    private func getTopView(with geo: GeometryProxy) -> some View {
        HStack {
            let weatherValue = widgetsViewModel.getCurrentWeatherData()
            VStack {
                Image(systemName: weatherValue.symbolName)
                    .resizable()
                    .scaledToFit()
                Text(weatherValue.formattedTemperature)
            }
            .frame(width: minSide / 2)
            HStack {
                BatteryView(font: widgetsViewModel.widgetData.textStyle.getFontWithSize(geo.size.height / 10), isVertical: true, foregroundColor: widgetsViewModel.widgetData.textColor.color, lineWidth: 1, padding: 1)
                    .frame(width: minSide / 3, height: geo.size.height / 3)
            }
            .frame(width: minSide / 2)
        }
        .frame(height: geo.size.height / 3)
    }
    
    private func getBottomView(with geo: GeometryProxy) -> some View {
        HStack {
            VStack {
                Image("calendar")
                    .resizable()
                    .scaledToFit()
                Text(Formatter.dayNumberMonthNameShort.string(from: widgetsViewModel.widgetData.date).uppercased())
            }
            .frame(width: minSide / 2)
            VStack {
                Image("storage")
                    .resizable()
                    .scaledToFit()
                Text(widgetsViewModel.availableStorage)
            }
            .frame(width: minSide / 2)
        }
        .frame(height: geo.size.height / 3)
    }
    
}

// MARK: - Preview

struct InfoWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        InfoWidgetView(previewAnimals: [UIImage(named: "cat_1_run_1")!, UIImage(named: "cat_1_run_2")!, UIImage(named: "cat_1_run_3")!, UIImage(named: "cat_1_run_4")!], bgImage: UIImage(named: "cat_1_normal")!)
            .preferredColorScheme(.light)
            .frame(width: 350, height: 350)
            .environmentObject(WidgetsViewModel())
    }
}
