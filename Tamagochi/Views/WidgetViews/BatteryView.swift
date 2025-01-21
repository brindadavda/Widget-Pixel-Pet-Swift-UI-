//
//  BatteryView.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI

// MARK: - HalfCircleShape

struct HalfCircleShape : Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addArc(center: CGPoint(x: rect.minX, y: rect.midY), radius: rect.height , startAngle: .degrees(90), endAngle: .degrees(270), clockwise: true)
        return path
    }
}

// MARK: - BatteryView

struct BatteryView: View {
    
    // MARK: - Properties
    
    let isVertical: Bool
    let font: Font
    let lineWidth: Double
    let padding: Double
    let foregroundColor: Color
    
    @State private var batteryLevel: Float = 1.0
    @State private var batterySize: CGSize = .zero
    @State private var batteryStatus: UIDevice.BatteryState = .unknown
    
    // MARK: - Inits
    
    init(font: Font, isVertical: Bool, foregroundColor: Color, lineWidth: Double = 3, padding: Double = 5) {
        self.font = font
        self.isVertical = isVertical
        self.lineWidth = lineWidth
        self.padding = padding
        self.foregroundColor = foregroundColor
        UIDevice.current.isBatteryMonitoringEnabled = true
    }
    
    // MARK: - Body
    
    var body: some View {
        makeUI()
    }
    
    // MARK: - UI
    
    private func makeUI() -> some View {
        GeometryReader { geo in
            Group {
                if isVertical {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            makeBattery(with: geo)
                                .offset(y: isVertical ? -5 : 0)
                            Spacer()
                        }
                        Spacer()
                        makeTextView()
                    }
                }
                else {
                    HStack(spacing: 0) {
                        makeBattery(with: geo)
                        makeTextView()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(foregroundColor)
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.batteryLevelDidChangeNotification), perform: { value in
                batteryLevel = UIDevice.current.batteryLevel
            })
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.batteryStateDidChangeNotification), perform: { value in
                withAnimation {
                    batteryStatus = UIDevice.current.batteryState
                }
            })
            .onAppear {
                batteryLevel = UIDevice.current.batteryLevel
            }
            .onAppear {
                withAnimation {
                    batteryStatus = UIDevice.current.batteryState
                }
            }
        }
    }
    
    private func makeBattery(with geo: GeometryProxy) -> some View {
        HStack(spacing: lineWidth) {
            let width = isVertical ? geo.size.width * 0.75 : geo.size.width * 0.5
            GeometryReader { rectangle in
                let rectangleWidth = rectangle.size.width
                let insideWidth = rectangleWidth - (rectangleWidth * (1 - CGFloat(batteryLevel))) > width / 6 ? rectangleWidth - (rectangleWidth * (1 - CGFloat(batteryLevel))) : width / 6
                RoundedRectangle(cornerRadius: geo.size.width * 0.05)
                    .stroke(lineWidth: lineWidth)
                RoundedRectangle(cornerRadius: insideWidth * 0.05 * (width / insideWidth))
                    .padding(padding)
                    .frame(width: insideWidth, height: geo.size.width * 0.25)
                    .foregroundColor(Color.getBatterLevelColor(of: Double(batteryLevel)))
                    .onAppear {
                        batterySize = rectangle.size
                    }
                HStack {
                    Spacer()
                    Image(systemName: "bolt.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.white)
                        .padding(.vertical, isVertical ? geo.size.height / 20 : geo.size.height / 4)
                        .opacity(batteryStatus == .charging ? 1 : 0)
                    Spacer()
                }
            }
            HalfCircleShape()
                .frame(width: width / 6, height: geo.size.width * 0.25 / 5)
        }
        .frame(width: isVertical ? geo.size.width * 0.75 : geo.size.width * 0.5, height: geo.size.width * 0.25)
    }
    
    private func makeTextView() -> some View {
        Text("\(Int(batteryLevel * 100)) %")
            .font(font)
            .foregroundColor(foregroundColor)
            .multilineTextAlignment(.center)
    }
    
}

// MARK: - Preview

struct BatteryView_Previews: PreviewProvider {
    static var previews: some View {
        BatteryView(font: .system(.body), isVertical: true, foregroundColor: .black)
            .preferredColorScheme(.light)
            .frame(width: 300, height: 100)
    }
}
