//
//  TickHands.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI

struct TickHands: View {
    
    // MARK: - Properties
    
    let maxInset: Double
    let maxLineWidth: Double
    let date: Date?
    
    @State private var currentDate = Date()

    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    // MARK: - Inits
    
    init(maxInset: Double, maxLineWidth: Double, date: Date? = nil) {
        self.maxInset = maxInset
        self.maxLineWidth = maxLineWidth
        self.date = date
    }
    
    // MARK: - Body
    
    var body: some View {
        makeUI()
    }
    
    // MARK: - UI
    
    private func makeUI() -> some View {
        ZStack {
            let date = self.date ?? currentDate
            Circle()
                .frame(width: maxLineWidth * 1.5, height: maxLineWidth * 1.5)
            Hand(inset: maxInset, angle: Angle(degrees: date.angleForHourHand()), isFromMid: true)
                .stroke(style: StrokeStyle(lineWidth: maxLineWidth / 3, lineCap: .round))
            Hand(inset: maxInset / 4, angle: Angle(degrees: date.angleForMinuteHand()), isFromMid: true)
                .stroke(style: StrokeStyle(lineWidth: maxLineWidth / 3, lineCap: .round))
            Hand(inset: maxInset, angle: Angle(degrees: date.angleForHourHand()), isFromMid: false)
                .stroke(style: StrokeStyle(lineWidth: maxLineWidth, lineCap: .round))
            Hand(inset: maxInset / 4, angle: Angle(degrees: date.angleForMinuteHand()), isFromMid: false)
                .stroke(style: StrokeStyle(lineWidth: maxLineWidth, lineCap: .round))
            Hand(inset: maxInset / 7, angle: Angle(degrees: date.angleForSecondHand()), extendArrow: true)
                .stroke(lineWidth: maxLineWidth / 3)
                .foregroundColor(Color(#colorLiteral(red: 1, green: 0.6531606317, blue: 0, alpha: 1)))
            Circle()
                .frame(width: maxLineWidth / 2, height: maxLineWidth / 2)
                .foregroundColor(.white)
        }
        .foregroundColor(.black)
        .onReceive(timer) { value in
            if date == nil {
                self.currentDate = Date()
            }
        }
    }
    
}

// MARK: - Preview

struct TickHands_Previews: PreviewProvider {
    static var previews: some View {
        TickHands(maxInset: 70, maxLineWidth: 10)
            .preferredColorScheme(.light)
    }
}
