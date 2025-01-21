//
//  Enums+Helpers.swift
//  Tamagochi
//
//  Created by Systems
//

import Foundation
import SwiftUI

enum TemperatureUnit: String {
    case celsius
    case fahrenheit
}

enum PixelPalAction: String, CaseIterable {
    case crouch
    case run
    case sleep
    case chill
}

enum EntertainmentType: String {
    case food
    case play
}

enum NavigationDestination: String {
    case dynamicIsland
    case liveActivity
    case widgetInstruction
    case transperentBG
    case widgetsBG
    case mainSettings
    case infoBG
}

enum WidgetInstruction: String {
    case home
    case lock
}

enum WidgetSize: String {
    case small
    case medium
}

enum TextStyle: String {
    case normal
    case serif
    case handwritten
    
    func getFontWithSize(_ fontSize: Double) -> Font {
        switch self {
        case .normal:
            return Font.custom("SF Pro Display", size: fontSize)
        case .serif:
            return Font.custom("Bitter", size: fontSize)
        case .handwritten:
            return Font.custom("Caveat", size: fontSize)
        }
    }

}

enum BGStyle: String {
    case transparent
    case photo
    case color
}

enum WidgetType_TamagochiVVV: String, CaseIterable, Identifiable, Codable {
    case clockText
    case clockTextAndDate
    case dateNumber
    case quoteSmall
    case quoteBig
    case battery
    case calendar
    case goodDay
    case info
    case weatherVertical
    case weatherHorizontal
    case multipleWeatherHorizontal
    case multipleWeatherVertical
    case multipleWeatherStyled
    case event
    case magicClock
    case clock
    case clockDetail
    
    var id: String {
        rawValue
    }
    
    var defaultBGColor: Color {
        switch self {
        case .multipleWeatherStyled, .multipleWeatherVertical, .multipleWeatherHorizontal:
            return Color.black
        default:
            return Color.white
        }
    }
    
}

enum Cats: String, CaseIterable, Identifiable {
    case luna
    case oliver
    case bella
    case leo
    case chloe
    case max
    case mia
    case charlie
    case lily
    case oscar
    case ruby
    case milo
    
    var id: Int {
        switch self {
            case .luna: return 1
            case .oliver: return 2
            case .bella: return 3
            case .leo: return 4
            case .chloe: return 5
            case .max: return 6
            case .mia: return 7
            case .charlie: return 8
            case .lily: return 9
            case .oscar: return 10
            case .ruby: return 11
            case .milo: return 12
        }
    }
    
    var weightInLbs: Double {
        switch self {
            case .luna: return 8.5
            case .oliver: return 11.2
            case .bella: return 9.0
            case .leo: return 10.8
            case .chloe: return 7.7
            case .max: return 12.3
            case .mia: return 8.9
            case .charlie: return 11.5
            case .lily: return 9.8
            case .oscar: return 13.0
            case .ruby: return 8.2
            case .milo: return 10.5
        }
    }
    
}

enum AlertType_TamagochiVVV: String {
    case heartInfo
    case rename
    case renameError
    case feedingInfo
    case feedingError
    case eventAlert
    case eventError
    case widgetAdded
    case widgetRemoved
    case photoName
    case samePhotoName
    
    func getTitle(with name: String = "") -> String {
        switch self {
        case .heartInfo:
            return "\(name) Friendship ❤️"
        case .rename:
            return "Rename"
        case .renameError, .eventError:
            return "Error"
        case .feedingInfo:
            return "Feeding \(name)"
        case .feedingError:
            return "\(name) has been fed recently"
        case .eventAlert:
            return "Enter event"
        case .widgetAdded, .widgetRemoved:
            return "Success"
        case .photoName:
            return "Photo Name"
        case .samePhotoName:
            return "Name already exists"
        }
    }
    
func getMessage(with name: String = "", maximumCharacters: Int = 10, and minimumCharacters: Int = 0) -> String {
        switch self {
        case .heartInfo:
            return "The heart bar indicates the level of friedship between you and \(name). To increase hearts, play with or feed yummy food to \(name)."
        case .rename:
            return "Don’t worry, stats are kept."
        case .renameError:
            if name.isEmpty {
                return "Name is empty, try again."
            }
            if name.containsOnlySpaces() {
                return "Name contains only spaces, try again."
            }
            if name.count > maximumCharacters {
                return "Name is too long(maximum \(maximumCharacters) symbols), try again."
            }
            if name.count < minimumCharacters {
                return "Name is too short(minimum \(minimumCharacters) symbols), try again."
            }
            return "Name is incorrect, try again."
        case .feedingInfo:
            return "While providing sustenance to real-life animals, ensure that you exclusively offer a diet sanctioned by a veterinarian."
        case .feedingError:
            return "You have already fed \(name) recently, so he is still full. Please wait for a short while before feeding him again."
        case .eventAlert:
            return ""
        case .eventError:
            if name.isEmpty {
                return "Event is empty, try again."
            }
            if name.containsOnlySpaces() {
                return "Event contains only spaces, try again."
            }
            if name.count > 30 {
                return "Event is too long(maximum 30 symbols), try again."
            }
            return "Name is incorrect, try again."
        case .widgetAdded:
            return "Congrats, you can now use this widget on Home Screen! 🤗"
        case .widgetRemoved:
            return "Sadly, but you can no longer use this widget 😭"
        case .photoName:
            return "Enter a name for the photo so you can find it later. The name must have at least 3 characters and less than 15 characters."
        case .samePhotoName:
            return "This will replace existing photo with this name. Are you sure?"
        }
    }
    
}

enum Food: String, CaseIterable, Identifiable {
    
    case meatbone
    case apple
    case corn
    case sushi
    case fish
    case bluebs
    case steak
    case carrot
    case watmelon
    
    var id: String {
        rawValue
    }
    
}

enum TamagochiInteractions: String {
    case none
    case ball
    case wand
    case feeding
}
