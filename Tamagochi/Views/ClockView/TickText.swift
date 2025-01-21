//
//  TickText.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI

struct TickText: View {
    
    // MARK: - Properties
    
    var ticks: [String]
    
    private struct IdentifiableTicks: Identifiable {
        var id: Int
        var tick: String
    }
    
    private var dataSource: [IdentifiableTicks] {
        self.ticks.enumerated().map { IdentifiableTicks(id: $0, tick: $1) }
    }
    
    // MARK: - Body
    
    var body: some View {
        makeUI()
    }
    
    // MARK: - UI
    
    private func makeUI() -> some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(self.dataSource) {
                    Text("\($0.tick)")
                        .position(
                            self.position(for: $0.id, in: proxy.frame(in: .local))
                        )
                }
            }
        }
    }
    
    private func position(for index: Int, in rect: CGRect) -> CGPoint {
        let inset = min(rect.width, rect.height) / 4.5
        let rect = rect.insetBy(dx: inset, dy: inset)
        let angle = ((2 * .pi) / CGFloat(ticks.count) * CGFloat(index)) - .pi/2
        let radius = min(rect.width, rect.height)/2
        return CGPoint(x: rect.midX + radius * cos(angle),
                       y: rect.midY + radius * sin(angle))
    }

}

// MARK: - Preview

struct TickText_Previews: PreviewProvider {
    static var previews: some View {
        TickText(ticks: [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11].map{"\($0)"})
    }
}
