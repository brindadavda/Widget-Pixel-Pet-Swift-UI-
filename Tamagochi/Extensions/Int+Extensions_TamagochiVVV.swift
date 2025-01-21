//
//  Int+Extensions.swift
//  Tamagochi
//
//  Created by Systems
//

import Foundation

typealias Int_TamagochiVVV = Int

extension Int_TamagochiVVV {
    
    func spelledOut() -> String? {
        let numberWords = [
            0: "zero", 1: "one", 2: "two", 3: "three", 4: "four",
            5: "five", 6: "six", 7: "seven", 8: "eight", 9: "nine",
            10: "ten", 11: "eleven", 12: "twelve", 13: "thirteen",
            14: "fourteen", 15: "fifteen", 16: "sixteen", 17: "seventeen",
            18: "eighteen", 19: "nineteen", 20: "twenty",
            30: "thirty", 40: "forty", 50: "fifty",
            60: "sixty", 70: "seventy", 80: "eighty", 90: "ninety"
        ]
        
        if let spelledOut = numberWords[self] {
            return spelledOut
        }
        
        guard self > 20, self < 100 else {
            return nil
        }
        
        let tens = (self / 10) * 10
        let ones = self % 10
        
        if let tensSpelledOut = numberWords[tens], let onesSpelledOut = numberWords[ones] {
            return "\(tensSpelledOut)-\(onesSpelledOut)"
        }
        
        return nil
    }
    
}
