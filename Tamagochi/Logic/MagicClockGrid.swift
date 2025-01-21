//
//  MagicClockGrid.swift
//  Tamagochi
//
//  Created by Systems
//

import Foundation

// struct, that represents logic of magic clock
class MagicClockGrid: ObservableObject {
    
    // MARK: - Properties
    
    private(set) var oldPhrase = ""
    
    private let randomLetters = "abcdefghijklmnopqrstuvwxyz"
    
    @Published private(set) var values = [[Character]]()
    
    // MARK: - Methods
    
    func updateGridAsync(with size: CGSize, and letterSize: CGSize, date: Date? = nil) async {
        let gridDimensions = calculateGridDimensions(withSize: size, and: letterSize)
        let result = await generateGrid(with: gridDimensions.rowCount, and: gridDimensions.columnCount, date: date)
        values = result
        if oldPhrase != Date.now.timeInWords() {
            oldPhrase = Date.now.timeInWords()
        }
    }
    
    func updateGrid(with size: CGSize, and letterSize: CGSize) {
        let gridDimensions = calculateGridDimensions(withSize: size, and: letterSize)
        Task {
            let result = await generateGrid(with: gridDimensions.rowCount, and: gridDimensions.columnCount)
            await MainActor.run {
                values = result
                if oldPhrase != Date.now.timeInWords() {
                    oldPhrase = Date.now.timeInWords()
                }
            }
        }
    }
    
    private func generateGrid(with rowCount: Int, and columnCount: Int, date: Date? = nil) async -> [[Character]] {
        var grid: [[Character]] = Array(repeating: Array(repeating: " ", count: columnCount), count: rowCount)
        let magicPhrase = date?.timeInWords() ?? Date.now.timeInWords()
        let magicPhraseWords = magicPhrase.components(separatedBy: " ")
        
        var currentRow = 0
        var currentColumn = 0
        
        for word in magicPhraseWords {
            for char in word {
                if currentRow < rowCount && currentColumn < columnCount {
                    grid[currentRow][currentColumn] = char
                    currentColumn += 1
                    
                    if currentColumn >= columnCount {
                        currentColumn = 0
                        currentRow += 1
                    }
                }
            }
            
            if currentRow >= rowCount {
                break
            }
            
            currentRow += Int.random(in: 1...2)
            
            // Add a bit of randomness to horizontal placement
            currentColumn += Int.random(in: -2...2)
            if currentColumn < 0 {
                currentColumn = 0
            } else if currentColumn >= columnCount {
                currentColumn = columnCount - 1
            }
        }
    
        // Fill the remaining empty spots with random characters
        for row in 0..<rowCount {
            for column in 0..<columnCount {
                if grid[row][column] == " " {
                    let randomChar = getRandomNonPhraseCharacter(with: magicPhrase)
                    grid[row][column] = randomChar
                }
            }
        }

        return grid
    }
    
    private func calculateGridDimensions(withSize size: CGSize, and letterSize: CGSize) -> (rowCount: Int, columnCount: Int) {
        if size.width > 0 && size.height > 0 {
            let columnCount = Int(size.width / letterSize.width)
            let rowCount = Int(size.height / letterSize.height)
            return (rowCount, columnCount)
        }
        return (0,0)
    }

    private func canPlaceWord(_ grid: [[Character]], _ word: String, _ row: Int, _ column: Int) -> Bool {
        for (index, char) in word.enumerated() {
            if grid[row][column + index] != " " && grid[row][column + index] != char {
                return false
            }
        }
        return true
    }
    
    private func getRandomNonPhraseCharacter(with phrase: String) -> Character {
        let nonPhraseCharacters = randomLetters.filter { !phrase.contains($0) }
        return nonPhraseCharacters.randomElement()!
    }
    
}
