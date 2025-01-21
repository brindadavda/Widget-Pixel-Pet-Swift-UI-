//
//  MagicClockView.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI

struct MagicClockView: WidgetView_TamagochiVVV {
    
    // MARK: - Properties
    
    @StateObject var magicClockGrid = MagicClockGrid()
    @EnvironmentObject var widgetsViewModel: WidgetsViewModel
    
    @State var minSide: Double = 1.0
    
    let type: WidgetType_TamagochiVVV = .magicClock
    let previewAnimals: [UIImage]
    let bgImage: UIImage
    let magicClockGridForWidget: MagicClockGrid?
    
    @State private var oldPhrase = ""
    
    // MARK: - Init
    
    init(previewAnimals: [UIImage], bgImage: UIImage, magicClockGridForWidget: MagicClockGrid? = nil) {
        self.previewAnimals = previewAnimals
        self.bgImage = bgImage
        self.magicClockGridForWidget = magicClockGridForWidget
    }
    
    // MARK: - Body
    
    var body: some View {
        makeUI()
    }
    
    // MARK: - UI
    
    private func makeUI() -> some View {
        GeometryReader { geo in
            if geo.size.width > 0 && geo.size.height > 0 {
                VStack(spacing: 0) {
                    makeMagicClock(with: geo)
                }
                .overlay {
                    makeOverlay(with: geo)
                }
                .animation(.easeInOut, value: magicClockGrid.oldPhrase)
                .onAppear {
                    updateClockOnResize(with: geo)
                }
                .onChange(of: widgetsViewModel.widgetData.date, perform: { newValue in
                    updateClock(with: geo, and: newValue)
                })
                .onChange(of: geo.size) { newValue in
                    minSide = min(newValue.width, newValue.height) - 30
                }
                .frame(maxWidth: geo.size.width, maxHeight: geo.size.height)
                .widgetModifier(with: widgetsViewModel.isForWidget ? 0 : minSide, and: getBackground(with: geo), foregroundColor: widgetsViewModel.widgetData.textColor.color)
            }
        }
    }
    
    private func updateClockOnResize(with geo: GeometryProxy) {
        minSide = min(geo.size.width, geo.size.height) - 30
        withAnimation {
            magicClockGrid.updateGrid(with: CGSize(width: geo.size.width - 30, height: geo.size.height - 30), and: CGSize(width: minSide / 12, height: minSide / 12))
        }
    }
    
    private func updateClock(with geo: GeometryProxy, and newValue: Date) {
        if oldPhrase != newValue.timeInWords() {
            oldPhrase = newValue.timeInWords()
            withAnimation {
                magicClockGrid.updateGrid(with: CGSize(width: geo.size.width - 30, height: geo.size.height - 30), and: CGSize(width: minSide / 12, height: minSide / 12))
            }
        }
    }
    
    @ViewBuilder
    private func makeOverlay(with geo: GeometryProxy) -> some View {
        if widgetsViewModel.shouldApplyOffset() {
            VStack {
                Spacer(minLength: minSide / 2)
                HStack {
                    getOverlay(with: geo, and: .zero)
                    Spacer()
                }
                .animation(.none, value: magicClockGrid.oldPhrase)
            }
        } else {
            getOverlay(with: geo, and: .zero)
        }
    }
    
    @ViewBuilder
    private func makeMagicClock(with geo: GeometryProxy) -> some View {
        let values = magicClockGridForWidget?.values ?? magicClockGrid.values
        let dateString = widgetsViewModel.widgetData.date.timeInWords()
        if !values.isEmpty {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(values, id: \.self) { row in
                    let rowText = row.map { String($0).uppercased() }.joined()
                    let attributedText = getAttributedText(from: dateString, and: rowText)
                    Text(attributedText)
                        .font(
                            widgetsViewModel.widgetData.textStyle.getFontWithSize(minSide / 15).weight(.regular))
                        .foregroundColor(widgetsViewModel.widgetData.textColor.color)
                        .frame(width: geo.size.width, height: minSide / 12)
                        .minimumScaleFactor(1)
                        .multilineTextAlignment(.leading)
                }
            }
        }
    }
    
    private func getAttributedText(from mainString: String, and secondaryString: String) -> AttributedString {
        var attributedText = AttributedString(secondaryString)
        let mainStringSet = Set(mainString.uppercased())
        var highlightedCharacters = 0
        for character in mainStringSet {
            if secondaryString.contains(character) {
                var searchRange = attributedText.startIndex..<attributedText.endIndex
                while let wordRange = attributedText[searchRange].range(of: String(character)) {
                    highlightedCharacters += 1
                    attributedText[wordRange].foregroundColor = widgetsViewModel.widgetData.textColor.color.oppositeColor
                    attributedText[wordRange].font = widgetsViewModel.widgetData.textStyle.getFontWithSize(minSide / 13).weight(.bold)
                    searchRange = wordRange.upperBound..<searchRange.upperBound
                }
            }
        }
        attributedText.kern = 5 - CGFloat(highlightedCharacters) * 0.025
        return attributedText
    }

}

// MARK: - Preview

struct MagicClockView_Previews: PreviewProvider {
    static var previews: some View {
        MagicClockView(previewAnimals: [UIImage(named: "cat_1_run_1")!, UIImage(named: "cat_1_run_2")!, UIImage(named: "cat_1_run_3")!, UIImage(named: "cat_1_run_4")!], bgImage: UIImage(named: "cat_1_normal")!)
            .preferredColorScheme(.light)
            .frame(width: 350, height: 350)
            .environmentObject(WidgetsViewModel())
    }
}
