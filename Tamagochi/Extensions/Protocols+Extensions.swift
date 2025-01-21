//
//  Protocols+Extensions.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI

protocol WidgetView_TamagochiVVV: View {
    
    var widgetsViewModel: WidgetsViewModel { get }
    var minSide: Double { get set }
    var type: WidgetType_TamagochiVVV { get }
    var previewAnimals: [UIImage] { get }
    var bgImage: UIImage { get }
    
}

extension WidgetView_TamagochiVVV {
    
    @ViewBuilder
    func getOverlay(with geo: GeometryProxy, and startOffset: CGSize) -> some View {
        if !previewAnimals.isEmpty {
            let reversedAnimation = widgetsViewModel.getAnimationStatus(of: type)
            let animationOffset = widgetsViewModel.getOffsetForAnimation(of: type)
            let index = widgetsViewModel.previewData[type]?.currentAnimalIndex
            if let index, index < previewAnimals.count {
                getAnimalImage(with: geo, and: previewAnimals[index], isBig: widgetsViewModel.widgetData.isBigPal)
                    .scaleEffect(x: reversedAnimation ? -1 : 1, y: 1)
                    .offset(startOffset)
                    .offset(x: animationOffset.x, y: animationOffset.y)
                    .background(
                        GeometryReader { viewGeometry in
                            Color.clear
                                .onChange(of: viewGeometry.size) { value in
                                    let superViewFrame = geo.frame(in: .global)
                                    let animalFrame = viewGeometry.frame(in: .global)
                                    let maxValueX = superViewFrame.maxX - animalFrame.maxX - startOffset.width
                                    let maxValueY = superViewFrame.maxY - animalFrame.maxY - startOffset.height
                                    let minValueX = superViewFrame.minX - animalFrame.minX - startOffset.width
                                    let minValueY = superViewFrame.minY - animalFrame.minY - startOffset.height
                                    widgetsViewModel.updateMaxValueForAnimation(of: type, with: CGPoint(x: maxValueX, y: maxValueY))
                                    widgetsViewModel.updateMinValueForAnimation(of: type, with: CGPoint(x: minValueX, y: minValueY))
                                }
                        }
                    )
            }
        }
    }
    
    @ViewBuilder
    func getBackground(with geo: GeometryProxy) -> some View {
        switch widgetsViewModel.widgetData.bgStyle {
        case .transparent:
            if widgetsViewModel.isForWidget {
                Color.clear
            } else {
                Color.clear
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(.black, lineWidth: 3)
                    )
            }
        case .photo:
            Image(uiImage: bgImage)
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width + geo.size.width * 0.1, height: geo.size.height + geo.size.height * 0.1)
        case .color:
            if widgetsViewModel.widgetData.bgColorHexString.isEmpty {
                widgetsViewModel.widgetData.bgColor.color
            } else {
                Color(hex: widgetsViewModel.widgetData.bgColorHexString)
            }
        }
    }
    
}
