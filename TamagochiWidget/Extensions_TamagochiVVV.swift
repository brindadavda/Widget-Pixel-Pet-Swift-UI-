//
//  Extensions.swift
//  TamagochiWidgetExtension
//
//  Created by Systems
//

import Foundation

extension Animals {
    
    var cat: Cats {
        switch self {
        case .unknown:
            return .luna
        case .luna:
            return .luna
        case .oliver:
            return .oliver
        case .bella:
            return .bella
        case .leo:
            return .leo
        case .chloe:
            return .chloe
        case .max:
            return .max
        case .mia:
            return .mia
        case .charlie:
            return .charlie
        case .lily:
            return .lily
        case .oscar:
            return .oscar
        case .ruby:
            return .ruby
        case .milo:
            return .milo
        }
    }
    
}

extension Action {
    
    var pixelPalAction: PixelPalAction {
        switch self {
        case .unknown:
            return .chill
        case .random:
            return PixelPalAction.allCases.randomElement() ?? .chill
        case .crouch:
            return .crouch
        case .run:
            return .run
        case .sleep:
            return .sleep
        case .chill:
            return .chill
        }
    }
    
}

extension InfoBackground {
    
    var widgetType: WidgetType_TamagochiVVV {
        WidgetType_TamagochiVVV(rawValue: identifier?.humanReadableToCamelCase() ?? "") ?? .battery
    }
    
}

extension Background {
    
    var photoID: Int {
        switch self {
        case .skyBlured:
            return 1
        case .gradientLight:
            return 2
        case .gradientDark:
            return 3
        case .warCamo:
            return 4
        case .pinkBlured:
            return 5
        case .spaceLight:
            return 6
        case .sky:
            return 7
        case .pinkWater:
            return 8
        case .gradientBlur:
            return 9
        case .waterLight:
            return 10
        case .waterDark:
            return 11
        case .winterBlur:
            return 12
        case .winter:
            return 13
        case .lines:
            return 14
        case .snowBlur:
            return 15
        case .spaceDark:
            return 16
        case .desert:
            return 17
        case .grass:
            return 18
        default:
            return -1
        }
    }
    
    var bgStyle: BGStyle {
        switch self {
        case .unknown:
            return .transparent
        case .default:
            return .transparent
        case .transparent, .customPhoto, .skyBlured, .gradientLight,
                .gradientDark, .warCamo, .pinkBlured, .spaceLight, .sky,
                .pinkWater, .gradientBlur, .waterLight, .waterDark, .winterBlur,
                .winter, .lines, .snowBlur, .spaceDark, .desert, .grass:
            return .photo
        case .lavenderMist, .skyBlue, .cobaltBlue, .aquaMint,
                .electricPurple, .lilacBliss, .fuchsiaFury,
                .royalPlum, .magentaBurst, .sunshineYellow,
                .firedBrick, .crimsonVelvet, .tangerineGlow,
                .forestGreen, .roseQuartz, .springBud, .azureBlue,
                .royalAmethyst, .hexString:
            return .color
        }
    }
    
    var color: AvailableColors {
        switch self {
        case .lavenderMist:
            return .lavenderMist
        case .skyBlue:
            return .skyBlue
        case .cobaltBlue:
            return .cobaltBlue
        case .aquaMint:
            return .aquaMint
        case .electricPurple:
            return .electricPurple
        case .lilacBliss:
            return .lilacBliss
        case .fuchsiaFury:
            return .fuchsiaFury
        case .royalPlum:
            return .royalPlum
        case .magentaBurst:
            return .magentaBurst
        case .sunshineYellow:
            return .sunshineYellow
        case .firedBrick:
            return .firedBrick
        case .crimsonVelvet:
            return .crimsonVelvet
        case .tangerineGlow:
            return .tangerineGlow
        case .forestGreen:
            return .forestGreen
        case .roseQuartz:
            return .roseQuartz
        case .springBud:
            return .springBud
        case .azureBlue:
            return .azureBlue
        case .royalAmethyst:
            return .royalAmethyst
        default:
            return .aquaMint
        }
    }
    
}

extension FontStyle {
    
    var textStyle: TextStyle {
        switch self {
        case .unknown:
            return .normal
        case .normal:
            return .normal
        case .serif:
            return .serif
        case .handwritten:
            return .handwritten
        }
    }
    
}

extension TextColor {
    
    var color: AvailableColors {
        switch self {
        case .unknown:
            return .black
        case .black:
            return .black
        case .white:
            return .white
        case .lavenderMist:
            return .lavenderMist
        case .skyBlue:
            return .skyBlue
        case .cobaltBlue:
            return .cobaltBlue
        case .aquaMint:
            return .aquaMint
        case .electricPurple:
            return .electricPurple
        case .lilacBliss:
            return .lilacBliss
        case .fuchsiaFury:
            return .fuchsiaFury
        case .royalPlum:
            return .royalPlum
        case .magentaBurst:
            return .magentaBurst
        case .sunshineYellow:
            return .sunshineYellow
        case .firedBrick:
            return .firedBrick
        case .crimsonVelvet:
            return .crimsonVelvet
        case .tangerineGlow:
            return .tangerineGlow
        case .forestGreen:
            return .forestGreen
        case .roseQuartz:
            return .roseQuartz
        case .springBud:
            return .springBud
        case .azureBlue:
            return .azureBlue
        case .royalAmethyst:
            return .royalAmethyst
        }
    }
    
}

