//
//  WidgetData.swift
//  Tamagochi
//
//  Created by Systems
//

import Foundation

// struct, that represents info about widget
struct WidgetData {
    
    // MARK: - Properties
    
    private(set) var selectedSize = WidgetSize.small
    private(set) var date: Date = .now
    private(set) var textStyle: TextStyle = .normal
    private(set) var bgStyle: BGStyle = .transparent
    private(set) var bgColor: AvailableColors = .aquaMint
    private(set) var textColor: AvailableColors = .black
    private(set) var bgColorHexString: String = ""
    private(set) var isBigPal: Bool = false
    
    // MARK: - Methods
    
    mutating func updateHexString(with newValue: String) {
        bgColorHexString = newValue
    }
    
    mutating func updateSize(with newValue: WidgetSize) {
        selectedSize = newValue
    }
    
    mutating func updateTextStyle(with newValue: TextStyle) {
        textStyle = newValue
    }
    
    mutating func updateBGColor(with newValue: AvailableColors) {
        bgColor = newValue
    }
    
    mutating func updateTextColor(with newValue: AvailableColors) {
        textColor = newValue
    }
    
    mutating func updateBGStyle(with newValue: BGStyle) {
        bgStyle = newValue
    }
    
    mutating func updateDate(with newValue: Date) {
        date = newValue
    }
    
    mutating func updateIsBigPal(with newValue: Bool) {
        isBigPal = newValue
    }
    
}
