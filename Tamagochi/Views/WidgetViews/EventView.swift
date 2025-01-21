//
//  EventView.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI

struct EventView: WidgetView_TamagochiVVV {
    
    // MARK: - Properties
    
    @EnvironmentObject var widgetsViewModel: WidgetsViewModel
    
    @State var minSide: Double = 1.0
    
    let type: WidgetType_TamagochiVVV = .event
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
                makeTextViews(with: geo)
            }
            .overlay {
                if widgetsViewModel.shouldApplyOffset() {
                    VStack {
                        HStack {
                            getOverlay(with: geo, and: .zero)
                            Spacer()
                        }
                        Spacer(minLength: minSide / 2)
                    }
                }
                else {
                    getOverlay(with: geo, and: .zero)
                }
            }
            .onAppear {
                minSide = min(geo.size.width, geo.size.height)
            }
            .onChange(of: geo.size) { newValue in
                minSide = min(newValue.width, newValue.height)
            }
            .font(widgetsViewModel.widgetData.textStyle.getFontWithSize(geo.size.width / 9))
            .frame(maxWidth: geo.size.width, maxHeight: geo.size.height)
            .widgetModifier(with: widgetsViewModel.isForWidget ? 0 : minSide, and: getBackground(with: geo), foregroundColor: widgetsViewModel.widgetData.textColor.color)
        }
    }
    
    @ViewBuilder
    private func makeTextViews(with geo: GeometryProxy) -> some View {
        Text(widgetsViewModel.currentEvent)
            .font(widgetsViewModel.widgetData.textStyle.getFontWithSize(geo.size.width / 7).weight(.semibold))
            .lineLimit(.max)
            .padding([.leading, .trailing])
            .minimumScaleFactor(0.5)
        Text(Date.now.daysLeftOrAgo(to: widgetsViewModel.currentEventDate))
            .padding(.top)
            .lineLimit(1)
            .minimumScaleFactor(0.2)
    }
    
}

// MARK: - Preview

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(previewAnimals: [UIImage(named: "cat_1_run_1")!, UIImage(named: "cat_1_run_2")!, UIImage(named: "cat_1_run_3")!, UIImage(named: "cat_1_run_4")!], bgImage: UIImage(named: "cat_1_normal")!)
            .preferredColorScheme(.light)
            .frame(width: 350, height: 350)
            .environmentObject(WidgetsViewModel())
    }
}
