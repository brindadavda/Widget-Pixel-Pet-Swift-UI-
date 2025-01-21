//
//  WeatherMultipleView.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI

struct WeatherMultipleView: WidgetView_TamagochiVVV {
    
    // MARK: - Properties
    
    @EnvironmentObject var widgetsViewModel: WidgetsViewModel
    
    @State var minSide: Double = 1.0
    
    let type: WidgetType_TamagochiVVV
    let previewAnimals: [UIImage]
    let bgImage: UIImage

    @State private var offsets = [Temperature: CGSize]()
    
    // MARK: - Body
    
    var body: some View {
        makeUI()
    }
    
    // MARK: - UI
    
    private func makeUI() -> some View {
        GeometryReader { geo in
            Group {
                if type == .multipleWeatherHorizontal || type == .multipleWeatherStyled {
                    getHorizontalView(with: geo)
                }
                else {
                    getVerticalView(with: geo)
                }
            }
            .onAppear {
                minSide = min(geo.size.width, geo.size.height)
            }
            .onChange(of: geo.size) { newValue in
                minSide = min(newValue.width, newValue.height)
            }
            .overlay {
                getOverlay(with: geo)
            }
            .font(widgetsViewModel.widgetData.textStyle.getFontWithSize(geo.size.height / 10))
            .frame(maxWidth: geo.size.width, maxHeight: geo.size.height)
            .widgetModifier(with: widgetsViewModel.isForWidget ? 0 : minSide, and: getBackground(with: geo), foregroundColor: widgetsViewModel.isForWidget ? widgetsViewModel.widgetData.textColor.color : .white)
        }
    }
    
    private func getVerticalView(with geo: GeometryProxy) -> some View {
        VStack {
            ForEach(widgetsViewModel.temperaturesData, id: \.self) { value in
                HStack {
                    Spacer()
                    Text(value.date.formattedHourWithAMPM())
                        .padding(.trailing)
                    Spacer()
                    Image(systemName: value.symbolName)
                        .font(.system(size: geo.size.height / 10))
                        .padding(.all)
                        .frame(width: geo.size.height / 10, height: geo.size.height / 10)
                        .foregroundColor(value.symbolName.contains("sun") ? .yellow : .white)
                    Spacer()
                    Text(value.formattedTemperature)
                        .padding(.leading)
                    Spacer()
                }
                .frame(width: minSide)
            }
        }
    }
    
    private func getHorizontalView(with geo: GeometryProxy) -> some View {
        HStack {
            ForEach(widgetsViewModel.temperaturesData, id: \.self) { value in
                VStack {
                    Text(value.date.formattedHourWithAMPM())
                        .padding(.bottom)
                    Image(systemName: value.symbolName)
                        .font(.system(size: geo.size.height / 10))
                        .padding([.top, .bottom])
                        .frame(height: geo.size.height / 10)
                        .foregroundColor(value.symbolName.contains("sun") ? .yellow : .white)
                    Text(value.formattedTemperature)
                        .padding(.top)
                }
                .font(widgetsViewModel.widgetData.textStyle.getFontWithSize(geo.size.height / 12))
                .frame(width: minSide / (Double(widgetsViewModel.temperaturesData.count) + 1))
                .offset(offsets[value] ?? .zero)
                .onAppear {
                    calculateOffsets(with: geo)
                }
            }
        }
    }
    
    @ViewBuilder
    private func getOverlay(with geo: GeometryProxy) -> some View {
        if !widgetsViewModel.shouldApplyOffset() {
            getOverlay(with: geo, and: .zero)
        } else {
            VStack {
                if type == .multipleWeatherStyled || type == .multipleWeatherVertical {
                    Spacer(minLength: minSide / 2)
                }
                HStack {
                    if type == .multipleWeatherStyled || type == .multipleWeatherHorizontal {
                        Spacer()
                    }
                    getOverlay(with: geo, and: .zero)
                    if type == .multipleWeatherVertical {
                        Spacer()
                    }
                }
                if type == .multipleWeatherHorizontal {
                    Spacer(minLength: minSide / 2)
                }
            }
        }
    }
    
    private func calculateOffsets(with geo: GeometryProxy) {
        var value = geo.size.height / 3
        for temperature in widgetsViewModel.temperaturesData {
            if type == .multipleWeatherStyled {
                offsets[temperature] = CGSize(width: 0, height: -Int(geo.size.height) / widgetsViewModel.temperaturesData.count + Int(value))
                value -= geo.size.height / 3 / CGFloat(widgetsViewModel.temperaturesData.count)
            }
            else {
                offsets[temperature] = .zero
            }
        }
    }
    
}

// MARK: - Preview

struct WeatherMultipleView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherMultipleView(type: .multipleWeatherVertical, previewAnimals: [UIImage(named: "cat_1_run_1")!, UIImage(named: "cat_1_run_2")!, UIImage(named: "cat_1_run_3")!, UIImage(named: "cat_1_run_4")!], bgImage: UIImage(named: "cat_1_normal")!)
            .preferredColorScheme(.dark)
            .frame(width: 350, height: 350)
            .environmentObject(WidgetsViewModel())
    }
}
