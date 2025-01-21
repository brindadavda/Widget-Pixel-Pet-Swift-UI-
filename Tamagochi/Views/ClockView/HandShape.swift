//
//  HandShape.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI

// shape, that represents arrow in clock
struct Hand: Shape {
    
    // MARK: - Properties
    
    let inset: CGFloat
    let angle: Angle
    let extendArrow: Bool
    let isFromMid: Bool
    
    // MARK: - Inits
    
    init(inset: CGFloat, angle: Angle, extendArrow: Bool = false, isFromMid: Bool = true) {
        self.inset = inset
        self.angle = angle
        self.extendArrow = extendArrow
        self.isFromMid = isFromMid
    }
    
    // MARK: - Methods
    
    func path(in rect: CGRect) -> Path {
        let rect = rect.insetBy(dx: inset, dy: inset)
        let minSide = min(rect.size.width, rect.size.height)
        var path = Path()
        if extendArrow {
            let specialRect = rect.insetBy(dx: minSide / 2.5, dy: minSide / 2.5)
            let startPos = position(for: CGFloat(angle.radians + .pi), in: specialRect)
            path.move(to: startPos)
            path.addLine(to: CGPoint(x: rect.midX, y: rect.midY))
        }
        if isFromMid {
            path.move(to: CGPoint(x: rect.midX, y: rect.midY))
            path.addRoundedRect(in: CGRect(x: rect.midX - 4, y: rect.midY - 4, width: 8, height: 8), cornerSize: CGSize(width: 8, height: 8))
            path.move(to: CGPoint(x: rect.midX, y: rect.midY))
        }
        else {
            let specialRect = rect.insetBy(dx: minSide / 2.3, dy: minSide / 2.3)
            path.move(to: position(for: CGFloat(angle.radians), in: specialRect))
        }
        path.addLine(to: position(for: CGFloat(angle.radians), in: rect))
        return path
    }
    
    private func position(for angle: CGFloat, in rect: CGRect) -> CGPoint {
        let angle = angle - (.pi/2)
        let radius = min(rect.width, rect.height)/2
        let xPosition = rect.midX + (radius * cos(angle))
        let yPosition = rect.midY + (radius * sin(angle))
        return CGPoint(x: xPosition, y: yPosition)
    }
    
}
