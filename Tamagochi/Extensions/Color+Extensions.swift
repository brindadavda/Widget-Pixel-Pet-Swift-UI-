//
//  Color+Extensions.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI

typealias Color_TamagochiVVV = Color

public extension Color_TamagochiVVV {
    
    var oppositeColor: Color {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let invertedRed = 1.0 - red
        let invertedGreen = 1.0 - green
        let invertedBlue = 1.0 - blue

        return Color(UIColor(red: invertedRed, green: invertedGreen, blue: invertedBlue, alpha: alpha))
    }
    
    init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.init(
            .sRGB,
            red: Double(red),
            green: Double(green),
            blue: Double(blue),
            opacity: Double(alpha)
        )
    }
    
    /// Initializes a SwiftUI `Color` with a hex string.
    ///
    /// - Parameters:
    ///   - hex: The hex color string (e.g., "#RRGGBB" or "#RRGGBBAA").
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        if hexSanitized.count == 6 {
            self.init(
                red: Double((rgb & 0xFF0000) >> 16) / 255.0,
                green: Double((rgb & 0x00FF00) >> 8) / 255.0,
                blue: Double(rgb & 0x0000FF) / 255.0
            )
        } else if hexSanitized.count == 8 {
            self.init(
                red: Double((rgb & 0xFF000000) >> 24) / 255.0,
                green: Double((rgb & 0x00FF0000) >> 16) / 255.0,
                blue: Double((rgb & 0x0000FF00) >> 8) / 255.0,
                opacity: Double(rgb & 0x000000FF) / 255.0
            )
        } else {
            self.init(red: 0, green: 0, blue: 0)
        }
    }

    static func random(randomOpacity: Bool = false) -> Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            opacity: randomOpacity ? .random(in: 0...1) : 1
        )
    }
    
    static func getBatterLevelColor(of batteryLevel: Double) -> Color {
        switch batteryLevel {
            case 0...0.2:
                return Color.red
            case 0.2...0.5:
                return Color.yellow
            case 0.5...1.0:
                return Color.green
            default:
                return Color.clear
        }
    }
    
}

enum AvailableColors: String, CaseIterable {
    case lavenderMist
    case skyBlue
    case cobaltBlue
    case aquaMint
    case electricPurple
    case lilacBliss
    case fuchsiaFury
    case royalPlum
    case magentaBurst
    case sunshineYellow
    case firedBrick
    case crimsonVelvet
    case tangerineGlow
    case forestGreen
    case roseQuartz
    case springBud
    case azureBlue
    case royalAmethyst
    case black
    case white
    
    var colorName: String {
        switch self {
        case .lavenderMist:
            return "Lavender Mist"
        case .skyBlue:
            return "Sky Blue"
        case .cobaltBlue:
            return "Cobalt Blue"
        case .aquaMint:
            return "Aqua Mint"
        case .electricPurple:
            return "Electric Purple"
        case .lilacBliss:
            return "Lilac Bliss"
        case .fuchsiaFury:
            return "Fuchsia Fury"
        case .royalPlum:
            return "Royal Plum"
        case .magentaBurst:
            return "Magenta Burst"
        case .sunshineYellow:
            return "Sunshine Yellow"
        case .firedBrick:
            return "Fired Brick"
        case .crimsonVelvet:
            return "Crimson Velvet"
        case .tangerineGlow:
            return "Tangerine Glow"
        case .forestGreen:
            return "Forest Green"
        case .roseQuartz:
            return "Rose Quartz"
        case .springBud:
            return "Spring Bud"
        case .azureBlue:
            return "Azure Blue"
        case .royalAmethyst:
            return "Royal Amethyst"
        case .black:
            return "Black"
        case .white:
            return "White"
        }
    }
    
    var color: Color {
        switch self {
        case .lavenderMist:
            return Color(red: 0.62, green: 0.52, blue: 0.98)
        case .skyBlue:
            return Color(red: 0.33, green: 0.8, blue: 1)
        case .cobaltBlue:
            return Color(red: 0.13, green: 0.47, blue: 0.99)
        case .aquaMint:
            return Color(red: 0.52, green: 0.98, blue: 0.95)
        case .electricPurple:
            return Color(red: 0.36, green: 0.19, blue: 0.98)
        case .lilacBliss:
            return Color(red: 0.82, green: 0.68, blue: 1)
        case .fuchsiaFury:
            return Color(red: 0.94, green: 0.26, blue: 1)
        case .royalPlum:
            return Color(red: 0.66, green: 0, blue: 0.72)
        case .magentaBurst:
            return Color(red: 1, green: 0.2, blue: 0.77)
        case .sunshineYellow:
            return Color(red: 1, green: 0.94, blue: 0.36)
        case .firedBrick:
            return Color(red: 1, green: 0.33, blue: 0.33)
        case .crimsonVelvet:
            return Color(red: 0.81, green: 0, blue: 0.15)
        case .tangerineGlow:
            return Color(red: 1, green: 0.5, blue: 0.29)
        case .forestGreen:
            return Color(red: 0.17, green: 0.52, blue: 0)
        case .roseQuartz:
            return Color(red: 0.98, green: 0.52, blue: 0.63)
        case .springBud:
            return Color(red: 0.81, green: 0.9, blue: 0.41)
        case .azureBlue:
            return Color(red: 0.37, green: 0.7, blue: 1)
        case .royalAmethyst:
            return Color(red: 0.42, green: 0.21, blue: 0.76)
        case .black:
            return .black
        case .white:
            return .white
        }
    }
    
}
