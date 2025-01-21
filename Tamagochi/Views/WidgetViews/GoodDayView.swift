//
//  GoodDayView.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI

struct GoodDayView: WidgetView_TamagochiVVV {
    
    // MARK: - Properties
    
    @EnvironmentObject var widgetsViewModel: WidgetsViewModel
    
    @State var minSide: Double = 1.0
    
    let type: WidgetType_TamagochiVVV = .goodDay
    let previewAnimals: [UIImage]
    let bgImage: UIImage
    
    // MARK: - Body
    
    var body: some View {
        makeUI()
    }
    
    // MARK: - UI
    
    private func makeUI() -> some View {
        GeometryReader { geo in
            VStack {
                getTextViews(with: geo)
                getInfoView(with: geo)
            }
            .minimumScaleFactor(1)
            .onAppear {
                minSide = min(geo.size.width, geo.size.height)
            }
            .onChange(of: geo.size) { newValue in
                minSide = min(newValue.width, newValue.height)
            }
            .overlay {
                if !widgetsViewModel.shouldApplyOffset() {
                    getOverlay(with: geo, and: .zero)
                } else if geo.size.width != geo.size.height {
                    HStack {
                        Spacer()
                        getOverlay(with: geo, and: CGSize(width: 0, height: -geo.size.height * 0.07 * 1.4))
                    }
                }
            }
            .frame(maxWidth: geo.size.width, maxHeight: geo.size.height)
            .widgetModifier(with: widgetsViewModel.isForWidget ? 0 : minSide, and: getBackground(with: geo), foregroundColor: widgetsViewModel.widgetData.textColor.color)
        }
    }
    
    private func getInfoView(with geo: GeometryProxy) -> some View {
        HStack {
            let weatherValue = widgetsViewModel.getCurrentWeatherData()
            Image(systemName: weatherValue.symbolName)
            Text(weatherValue.formattedTemperature)
                .font(widgetsViewModel.widgetData.textStyle.getFontWithSize(geo.size.height / 12))
            BatteryView(font: widgetsViewModel.widgetData.textStyle.getFontWithSize(geo.size.height / 12), isVertical: false, foregroundColor: widgetsViewModel.widgetData.textColor.color, lineWidth: 1, padding: 1)
                .frame(width: min(geo.size.width, geo.size.height) * 0.5)
                .padding(.leading)
        }
        .frame(width: minSide, height: geo.size.height * 0.13)
        .padding(.top)
        .overlay {
            if geo.size.width == geo.size.height && widgetsViewModel.shouldApplyOffset() {
                HStack {
                    Spacer()
                    getOverlay(with: geo, and: CGSize(width: -geo.size.width / 9, height: -geo.size.height * 0.07 * 1.4))
                }
            }
        }
    }
    
    @ViewBuilder
    private func getTextViews(with geo: GeometryProxy) -> some View {
        Group {
            Text(widgetsViewModel.widgetData.date.greetingBasedOnTime().uppercased())
                .font(widgetsViewModel.widgetData.textStyle.getFontWithSize(geo.size.height / 13))
                .padding(.all)
            Text(widgetsViewModel.widgetData.date, style: .time)
                .font(widgetsViewModel.widgetData.textStyle.getFontWithSize(geo.size.height / 13).weight(.medium))
            Text(Formatter.dayDate.string(from: widgetsViewModel.widgetData.date).uppercased())
                .font(widgetsViewModel.widgetData.textStyle.getFontWithSize(geo.size.height / 14))
        }
        .frame(width: minSide, height: geo.size.height * 0.13)
    }
    
}

// MARK: - Preview

struct GoodDayView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = WidgetsViewModel()
        GoodDayView(previewAnimals: [UIImage(named: "cat_1_run_1")!, UIImage(named: "cat_1_run_2")!, UIImage(named: "cat_1_run_3")!, UIImage(named: "cat_1_run_4")!], bgImage: UIImage(named: "cat_1_normal")!)
            .preferredColorScheme(.light)
            .frame(width: 350, height: 350)
            .environmentObject(vm)
            .onAppear {
                vm.selectedTextStyle = .handwritten
            }
    }
}
