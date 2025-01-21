//
//  Temperature.swift
//  Tamagochi
//
//  Created by Systems
//

import Foundation

// struct, that represents temperature
struct Temperature: Hashable {
    
    // MARK: - Properties
    
    let date: Date
    let symbolName: String
    let value: Int
    
    var formattedTemperature: String {
        "\(value)°"
    }
    
}
