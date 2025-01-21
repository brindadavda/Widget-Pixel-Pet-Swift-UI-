//
//  ClockView.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI

struct ClockView: View {
    
    // MARK: - Properties
    
    let date: Date?
    let foregroundColor: Color
    
    // MARK: - Inits
    
    init(foregroundColor: Color, date: Date? = nil) {
        self.date = date
        self.foregroundColor = foregroundColor
    }
    
    // MARK: - Body
    
    var body: some View {
        makeUI()
    }
    
    // MARK: - UI
    
    private func makeUI() -> some View {
        GeometryReader { geo in
            let minSide = min(geo.size.width, geo.size.height)
            ZStack {
                Ticks(inset: 8, minTickHeight: minSide / 10, hourTickHeight: minSide / 10, totalTicks: 60)
                    .stroke(lineWidth: minSide / 100)
                    .foregroundColor(foregroundColor.oppositeColor)
                Ticks(inset: 8, minTickHeight: minSide / 10, hourTickHeight: minSide / 10, totalTicks: 12)
                    .stroke(lineWidth: minSide / 100)
                    .foregroundColor(foregroundColor)
                TickText(
                    ticks: [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11].map{"\($0)"}
                )
                .foregroundColor(foregroundColor)
                TickHands(maxInset: minSide / 3, maxLineWidth: minSide / 40, date: date)
            }
            .background {
                VStack(spacing: minSide / 6) {
                    Text(TimeZone.currentUserTimeZoneGMTString())
                    Text(TimeZone.currentUserUTCOffsetString())
                }
                .foregroundColor(foregroundColor.oppositeColor)
            }
        }
    }
    
}

// MARK: - Preview

struct ClockView_Previews: PreviewProvider {
    static var previews: some View {
        ClockView(foregroundColor: .black)
            .preferredColorScheme(.light)
    }
}
