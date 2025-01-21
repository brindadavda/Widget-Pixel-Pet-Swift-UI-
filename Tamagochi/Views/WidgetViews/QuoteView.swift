//
//  QuoteView.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI

struct QuoteView: WidgetView_TamagochiVVV {
    
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
            VStack {
                Spacer()
                VStack {
                    let quote = widgetsViewModel.quotes[type] ?? Quote(text: "Bla", author: "Bla")
                    makeTextView(with: widgetsViewModel.widgetData.textStyle.getFontWithSize(geo.size.height / 8), and: quote.text)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    if type == .quoteBig {
                        getAuthorView(with: geo, and: quote.author)
                    }
                }
                .overlay {
                    if type == .quoteSmall || !widgetsViewModel.shouldApplyOffset() {
                        HStack {
                            getOverlay(with: geo, and: getOffsetForAnimalImage(with: geo))
                            if widgetsViewModel.shouldApplyOffset() {
                                Spacer()
                            }
                        }
                    }
                }
                Spacer()
            }
            .lineLimit(.max)
            .onAppear {
                minSide = min(geo.size.width, geo.size.height)
            }
            .onChange(of: geo.size) { newValue in
                minSide = min(newValue.width, newValue.height)
            }
            .widgetModifier(with: widgetsViewModel.isForWidget ? 0 : minSide, and: getBackground(with: geo), foregroundColor: widgetsViewModel.widgetData.textColor.color)
        }
    }
    
    private func getAuthorView(with geo: GeometryProxy, and author: String) -> some View {
        HStack {
            Spacer()
            Image("quote")
                .resizable()
                .scaledToFit()
                .frame(height: geo.size.height / 6)
            makeTextView(with: widgetsViewModel.widgetData.textStyle.getFontWithSize(geo.size.height / 10)
                .weight(getFontWeight()), and: author)
            Spacer()
        }
        .overlay {
            if widgetsViewModel.shouldApplyOffset() {
                HStack {
                    Spacer()
                    getOverlay(with: geo, and: getOffsetForAnimalImage(with: geo))
                }
                .padding(.zero)
            }
        }
    }
    
    private func getFontWeight() -> Font.Weight {
        switch widgetsViewModel.widgetData.textStyle {
        case .normal, .serif:
            return .medium
        case .handwritten:
            return .bold
        }
    }
    
    private func makeTextView(with font: Font, and text: String) -> some View {
        Text(text)
            .font(font)
            .padding([.leading, .trailing])
            .multilineTextAlignment(.leading)
            .frame(maxHeight: .infinity)
    }
    
    private func getOffsetForAnimalImage(with geo: GeometryProxy) -> CGSize {
        if !widgetsViewModel.shouldApplyOffset() {
            return .zero
        } else {
            if type == .quoteSmall {
                return CGSize(width: 0, height: -geo.size.height / 3)
            }
            else {
                return CGSize(width: 0, height: -geo.size.height / 5)
            }
        }
    }
    
}

// MARK: - Preview

struct QuoteView_Previews: PreviewProvider {
    static var previews: some View {
        QuoteView(type: .quoteSmall, previewAnimals: [UIImage(named: "cat_1_run_1")!, UIImage(named: "cat_1_run_2")!, UIImage(named: "cat_1_run_3")!, UIImage(named: "cat_1_run_4")!], bgImage: UIImage(named: "cat_1_normal")!)
            .preferredColorScheme(.light)
            .frame(width: 350, height: 350)
            .environmentObject(WidgetsViewModel())
    }
}
