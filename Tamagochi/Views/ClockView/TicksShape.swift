//
//  TicksShape.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI

// shape, that represents ticks in clock
struct Ticks: Shape {
    
    // MARK: - Properties
    
    let inset: CGFloat
    let minTickHeight: CGFloat
    let hourTickHeight: CGFloat
    let totalTicks: Int
    let hourTickInterval: Int = 5
    
    // MARK: - Methods
    
    func path(in rect: CGRect) -> Path {
        let rect = rect.insetBy(dx: inset, dy: inset)
        var path = Path()
        for index in 0..<totalTicks {
            let condition = index % hourTickInterval == 0
            let height: CGFloat = condition ? hourTickHeight : minTickHeight
            path.move(to: topPosition(for: angle(for: index), in: rect))
            path.addLine(to: bottomPosition(for: angle(for: index), in: rect, height: height))
        }
        return path
    }
    
    private func angle(for index: Int) -> CGFloat {
        return (2 * .pi / CGFloat(totalTicks)) * CGFloat(index)
    }
    
    private func topPosition(for angle: CGFloat, in rect: CGRect) -> CGPoint {
        let radius = min(rect.height, rect.width)/2
        let xPosition = rect.midX + (radius * cos(angle))
        let yPosition = rect.midY + (radius * sin(angle))
        return CGPoint(x: xPosition, y: yPosition)
    }
    
    private func bottomPosition(for angle: CGFloat, in rect: CGRect, height: CGFloat) -> CGPoint {
        let radius = min(rect.height, rect.width)/2
        let xPosition = rect.midX + ((radius - height) * cos(angle))
        let yPosition = rect.midY + ((radius - height) * sin(angle))
        return CGPoint(x: xPosition, y: yPosition)
    }
    
}
