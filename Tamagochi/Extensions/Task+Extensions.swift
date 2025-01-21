//
//  Task+Extensions.swift
//  Tamagochi
//
//  Created by Systems
//

import Foundation

typealias Task_TamagochiVVV = Task

extension Task_TamagochiVVV where Success == Never, Failure == Never {
    
    static func sleep(seconds: Double) async {
        try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
    
}
