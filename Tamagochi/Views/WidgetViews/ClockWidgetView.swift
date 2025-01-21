//
//  ClockWidgetView.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI

struct ClockWidgetView: WidgetView_TamagochiVVV {
    
    // MARK: - Properties
    
    @EnvironmentObject var widgetsViewModel: WidgetsViewModel
    
    @State var minSide: Double = 1.0
    
    let type: WidgetType_TamagochiVVV
    let previewAnimals: [UIImage]
    let bgImage: UIImage
    
    // MARK: - Body
    
    var body: some View {
        makeUI()
    }
    
    // MARK: - UI
    
    private func makeUI() -> some View {
        GeometryReader { geo in
            Group {
                if geo.size.width > geo.size.height {
                    HStack {
                        makeClockView(with: geo)
                        if type == .clockDetail {
                            VStack {
                                makeTextViews(with: geo)
                            }
                        }
                    }
                } else {
                    VStack {
                        makeClockView(with: geo)
                        if type == .clockDetail {
                            makeTextViews(with: geo)
                        }
                    }
                }
            }
            .frame(maxWidth: geo.size.width, maxHeight: geo.size.height)
            .overlay {
                makeOverlay(with: geo)
            }
            .onAppear {
                minSide = min(geo.size.width, geo.size.height)
            }
            .onChange(of: geo.size) { newValue in
                minSide = min(newValue.width, newValue.height)
            }
            .font(widgetsViewModel.widgetData.textStyle.getFontWithSize(min(geo.size.width, geo.size.height) / 15))
            .padding(.all)
            .widgetModifier(with: widgetsViewModel.isForWidget ? 0 : minSide, and: getBackground(with: geo), foregroundColor: widgetsViewModel.widgetData.textColor.color)
        }
    }
    
    @ViewBuilder
    private func makeClockView(with geo: GeometryProxy) -> some View {
        if type == .clockDetail && geo.size.width <= geo.size.height {
            ClockView(foregroundColor: widgetsViewModel.widgetData.textColor.color, date: widgetsViewModel.widgetData.date)
                .font(widgetsViewModel.widgetData.textStyle.getFontWithSize(min(geo.size.width, geo.size.height) / 25))
        }
        else {
            ClockView(foregroundColor: widgetsViewModel.widgetData.textColor.color, date: widgetsViewModel.widgetData.date)
                .font(widgetsViewModel.widgetData.textStyle.getFontWithSize(min(geo.size.width, geo.size.height) / 15))
        }
    }
    
    @ViewBuilder
    private func makeTextViews(with geo: GeometryProxy) -> some View {
        makeTextView(with: widgetsViewModel.widgetData.textStyle.getFontWithSize(geo.size.width > geo.size.height ? geo.size.height / 6 : geo.size.height / 9), isDate: false, geo: geo)
        makeTextView(with: widgetsViewModel.widgetData.textStyle.getFontWithSize(geo.size.width > geo.size.height ? geo.size.height / 10 : geo.size.height / 13), isDate: true, geo: geo)
    }
    
    @ViewBuilder
    private func makeOverlay(with geo: GeometryProxy) -> some View {
        if widgetsViewModel.shouldApplyOffset() {
            VStack {
                if type == .clockDetail {
                    Spacer()
                }
                HStack {
                    getOverlay(with: geo, and: .zero)
                    Spacer()
                }
                if type == .clock {
                    Spacer()
                }
            }
        } else {
            getOverlay(with: geo, and: .zero)
        }
    }
    
    private func makeTextView(with font: Font, isDate: Bool = false, geo: GeometryProxy) -> some View {
        Group {
            if isDate {
                Text(Formatter.dayDate.string(from: widgetsViewModel.widgetData.date))
                    .minimumScaleFactor(0.4)
                    .fontWeight(getFontWeightBottomText())
            } else {
                Text(widgetsViewModel.widgetData.date, style: .time)
                    .minimumScaleFactor(0.2)
                    .fontWeight(getFontWeightTopText())
            }
        }
        .frame(maxWidth: .infinity)
        .font(
            font
        )
    }
    
    private func getFontWeightTopText() -> Font.Weight {
        switch widgetsViewModel.widgetData.textStyle {
        case .normal, .serif:
            return .medium
        case .handwritten:
            return .bold
        }
    }
    
    private func getFontWeightBottomText() -> Font.Weight {
        switch widgetsViewModel.widgetData.textStyle {
        case .normal, .handwritten:
            return .regular
        case .serif:
            return .medium
        }
    }
    
}

// MARK: - Preview

struct ClockWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        ClockWidgetView(type: .clockDetail, previewAnimals: [UIImage(named: "cat_1_run_1")!, UIImage(named: "cat_1_run_2")!, UIImage(named: "cat_1_run_3")!, UIImage(named: "cat_1_run_4")!], bgImage: UIImage(named: "cat_1_normal")!)
            .preferredColorScheme(.light)
            .frame(width: 350, height: 350)
            .environmentObject(WidgetsViewModel())
    }
}
