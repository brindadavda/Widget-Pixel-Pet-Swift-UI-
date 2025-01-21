//
//  ClockTextAndDate.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI

struct ClockTextAndDate: WidgetView_TamagochiVVV {
    
    // MARK: - Properties
    
    @EnvironmentObject var widgetsViewModel: WidgetsViewModel
    
    @State var minSide: Double = 1.0
    
    let type: WidgetType_TamagochiVVV = .clockTextAndDate
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
                Spacer()
                HStack {
                    Spacer()
                    VStack {
                        makeTextView(with: widgetsViewModel.widgetData.textStyle.getFontWithSize(geo.size.height / 4), isDate: false, geo: geo)
                        makeTextView(with: widgetsViewModel.widgetData.textStyle.getFontWithSize(geo.size.height / 8), isDate: true, geo: geo)
                    }
                    .overlay {
                        getOverlay(with: geo, and: getOffsetForAnimalImage(with: geo))
                    }
                    Spacer()
                }
                Spacer()
            }
            .onAppear {
                minSide = min(geo.size.width, geo.size.height)
            }
            .onChange(of: geo.size) { newValue in
                minSide = min(newValue.width, newValue.height)
            }
            .widgetModifier(with: widgetsViewModel.isForWidget ? 0 : minSide, and: getBackground(with: geo), foregroundColor: widgetsViewModel.widgetData.textColor.color)
        }
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
    
    private func getOffsetForAnimalImage(with geo: GeometryProxy) -> CGSize {
        if !widgetsViewModel.shouldApplyOffset() {
            return .zero
        } else {
            if geo.size.width == geo.size.height {
                return CGSize(width: geo.size.width / 4.5, height: -geo.size.height / 5)
            }
            else {
                return CGSize(width: geo.size.width / 8.5, height: -geo.size.height / 5)
            }
        }
    }
    
}

// MARK: - Preview

struct ClockTextAndDate_Previews: PreviewProvider {
    static var previews: some View {
        ClockTextAndDate(previewAnimals: [UIImage(named: "cat_1_run_1")!, UIImage(named: "cat_1_run_2")!, UIImage(named: "cat_1_run_3")!, UIImage(named: "cat_1_run_4")!], bgImage: UIImage(named: "cat_1_normal")!)
            .preferredColorScheme(.light)
            .frame(width: 600, height: 400)
            .environmentObject(WidgetsViewModel())
    }
}
