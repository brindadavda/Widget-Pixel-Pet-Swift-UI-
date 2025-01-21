//
//  BatteryWidgetView.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI

struct BatteryWidgetView: WidgetView_TamagochiVVV {
    
    // MARK: - Properties
    
    @EnvironmentObject var widgetsViewModel: WidgetsViewModel
    
    @State var minSide: Double = 1.0
    
    let type: WidgetType_TamagochiVVV = .battery
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
                BatteryView(font: widgetsViewModel.widgetData.textStyle.getFontWithSize(geo.size.height / 8).weight(getFontWeight()), isVertical: false, foregroundColor: widgetsViewModel.widgetData.textColor.color)
                    .frame(width: minSide, height: geo.size.height * 0.2)
                    .overlay {
                        HStack {
                            getOverlay(with: geo, and: getOffsetForAnimalImage(with: geo))
                            if widgetsViewModel.shouldApplyOffset() {
                                Spacer()
                            }
                        }
                        .padding(.zero)
                    }
            }
            .onAppear {
                minSide = min(geo.size.width, geo.size.height)
            }
            .onChange(of: geo.size) { newValue in
                minSide = min(newValue.width, newValue.height)
            }
            .frame(maxWidth: geo.size.width, maxHeight: geo.size.height)
            .widgetModifier(with: widgetsViewModel.isForWidget ? 0 : minSide, and: getBackground(with: geo), foregroundColor: widgetsViewModel.widgetData.textColor.color)
        }
    }
    
    private func getFontWeight() -> Font.Weight {
        switch widgetsViewModel.widgetData.textStyle {
        case .normal:
            return .regular
        case .serif:
            return .medium
        case .handwritten:
            return .bold
        }
    }
    
    private func getOffsetForAnimalImage(with geo: GeometryProxy) -> CGSize {
        if !widgetsViewModel.shouldApplyOffset() {
            return .zero
        } else {
            return CGSize(width: 0, height: -geo.size.height / 7)
        }
    }
    
}

// MARK: - Preview

struct BatteryWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        BatteryWidgetView(previewAnimals: [UIImage(named: "cat_1_run_1")!, UIImage(named: "cat_1_run_2")!, UIImage(named: "cat_1_run_3")!, UIImage(named: "cat_1_run_4")!], bgImage: UIImage(named: "cat_1_normal")!)
            .preferredColorScheme(.light)
            .frame(width: 350, height: 350)
            .environmentObject(WidgetsViewModel())
    }
}
