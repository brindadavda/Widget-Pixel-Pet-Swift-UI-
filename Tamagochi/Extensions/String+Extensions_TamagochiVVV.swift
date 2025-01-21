//
//  String+Extensions.swift
//  Tamagochi
//
//  Created by Systems
//

import Foundation

typealias String_TamagochiVVV = String

extension String_TamagochiVVV {
    
    func capitalizeFirstLetter() -> String {
        guard let firstLetter = self.first else {
            return self
        }
        return String(firstLetter).capitalized + dropFirst()
    }
    
    func wordsArray() -> [String] {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }
    }
    
    func containsOnlySpaces() -> Bool {
        let trimmed = self.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty
    }
    
    func camelCaseToHumanReadable() -> String {
        // Create a character set for detecting uppercase letters
        let uppercaseSet = CharacterSet.uppercaseLetters

        // Iterate through the characters in the string
        var result = ""
        var previousCharWasUppercase = false
        
        for char in self {
            if uppercaseSet.contains(char.unicodeScalars.first!) {
                // If the current character is uppercase, and the previous character
                // was not, add a space before adding the character.
                if !previousCharWasUppercase {
                    result.append(" ")
                }
                result.append(char)
                previousCharWasUppercase = true
            } else {
                result.append(char)
                previousCharWasUppercase = false
            }
        }

        // Capitalize the first letter and remove leading spaces
        result = result.trimmingCharacters(in: .whitespacesAndNewlines)
        result = result.capitalized
        
        return result
    }
    
    func humanReadableToCamelCase() -> String {
        let words = self.components(separatedBy: CharacterSet.whitespaces)
        var camelCaseString = ""
        
        for (index, word) in words.enumerated() {
            if index == 0 {
                camelCaseString.append(word.lowercased())
            } else {
                camelCaseString.append(word.capitalized)
            }
        }
        
        return camelCaseString
    }
    
}
