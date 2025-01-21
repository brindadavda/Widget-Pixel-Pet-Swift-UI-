//
//  WeatherTextView.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI

struct WeatherTextView: WidgetView_TamagochiVVV {
    
    // MARK: - Properties
    
    @EnvironmentObject var widgetsViewModel: WidgetsViewModel
    
    @State var minSide: Double = 1.0
    
    let type: WidgetType_TamagochiVVV
    let previewAnimals: [UIImage]
    let bgImage: UIImage
    
    @State private var rowWidth = 0.0
    
    // MARK: - Body
    
    var body: some View {
        makeUI()
    }
    
    // MARK: - UI
    
    private func makeUI() -> some View {
        GeometryReader { geo in
            HStack {
                if type == .weatherVertical {
                    makeVerticalView(with: geo)
                } else {
                    makeHorizontalView(with: geo)
                }
            }
            .overlay {
                if !widgetsViewModel.shouldApplyOffset() {
                    getOverlay(with: geo, and: .zero)
                }
            }
            .onAppear {
                minSide = min(geo.size.width, geo.size.height)
            }
            .onChange(of: geo.size) { newValue in
                minSide = min(newValue.width, newValue.height)
            }
            .padding(.all)
            .font(widgetsViewModel.widgetData.textStyle.getFontWithSize(geo.size.height / 6).weight(.semibold))
            .frame(maxWidth: geo.size.width, maxHeight: geo.size.height)
            .widgetModifier(with: widgetsViewModel.isForWidget ? 0 : minSide, and: getBackground(with: geo), foregroundColor: widgetsViewModel.widgetData.textColor.color)
        }
    }
    
    @ViewBuilder
    private func makeVerticalView(with geo: GeometryProxy) -> some View {
        let minSide = min(geo.size.width, geo.size.height)
        let weatherValue = widgetsViewModel.getCurrentWeatherData()
        VStack(spacing: 30) {
            HStack {
                Image(systemName: weatherValue.symbolName)
                    .font(.system(size: geo.size.height / 6))
                    .frame(height: geo.size.height / 6)
                Spacer()
            }
            .frame(width: rowWidth)
            HStack {
                Text(weatherValue.formattedTemperature)
                    .frame(width: minSide / 4)
                if widgetsViewModel.shouldApplyOffset() {
                    getOverlay(with: geo, and: .zero)
                        .frame(width: minSide / 4)
                }
                else {
                    Spacer()
                        .frame(width: minSide / 4)
                }
            }
            .background {
                GeometryReader { row in
                    Color.clear
                        .onAppear {
                            self.rowWidth = row.size.width
                        }
                }
            }
        }
    }
    
    @ViewBuilder
    private func makeHorizontalView(with geo: GeometryProxy) -> some View {
        let minSide = min(geo.size.width, geo.size.height)
        let weatherValue = widgetsViewModel.getCurrentWeatherData()
        HStack {
            Image(systemName: weatherValue.symbolName)
                .font(.system(size: geo.size.height / 6))
                .frame(height: geo.size.height / 6)
            Text(weatherValue.formattedTemperature)
                .padding(.leading)
                .frame(width: minSide / 3)
        }
        .overlay {
            if widgetsViewModel.shouldApplyOffset() {
                HStack {
                    getOverlay(with: geo, and: CGSize(width: -25, height: -geo.size.height / 7))
                    Spacer()
                }
            }
        }
    }
    
}

// MARK: - Preview

struct WeatherTextView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherTextView(type: .weatherHorizontal, previewAnimals: [UIImage(named: "cat_1_run_1")!, UIImage(named: "cat_1_run_2")!, UIImage(named: "cat_1_run_3")!, UIImage(named: "cat_1_run_4")!], bgImage: UIImage(named: "cat_1_normal")!)
            .preferredColorScheme(.light)
            .frame(width: 350, height: 350)
            .environmentObject(WidgetsViewModel())
    }
}
