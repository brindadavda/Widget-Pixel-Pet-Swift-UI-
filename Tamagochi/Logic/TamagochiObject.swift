//
//  TamagochiObject.swift
//  Tamagochi
//
//  Created by Systems
//

import Foundation

struct TamagochiObject: Hashable, Identifiable {
    
    // MARK: - Properties
    
    private typealias constants = TamagochiObjectConstants
    
    let startName: Cats
    let creationDate: Date
    let id: Int
    let normalImageData: Data
    let lieImageData: Data
    let sitImageData: Data
    let imagesData: [PixelPalAction: [Data]]
    
    private(set) var weight: Double
    private(set) var health: Int
    private(set) var name: String
    private(set) var scrolledEogether: Double
    private(set) var lastTimeFed: Date
    private(set) var lastTimePlayed: Date
    
    // MARK: - Inits
    
    init(id: Int, imagesData: [PixelPalAction: [Data]], normalImageData: Data, lieImageData: Data, sitImageData: Data, weight: Double, startName: Cats, health: Int) {
        self.id = id
        self.imagesData = imagesData
        self.normalImageData = normalImageData
        self.lieImageData = lieImageData
        self.sitImageData = sitImageData
        self.weight = weight
        self.startName = startName
        self.creationDate = .now
        self.scrolledEogether = 0.0
        self.health = health
        self.name = ""
        self.lastTimeFed = Date(timeIntervalSince1970: .zero)
        self.lastTimePlayed = Date(timeIntervalSince1970: .zero)
    }
    
    init(from coreDataObject: TamagochiEntity) {
        self.startName = Cats(rawValue: coreDataObject.startName ?? "") ?? .luna
        self.weight = coreDataObject.weight
        self.creationDate = coreDataObject.creationDate ?? .now
        self.health = Int(coreDataObject.health)
        self.name = coreDataObject.name ?? ""
        self.scrolledEogether = coreDataObject.scrolledEogether
        self.lastTimeFed = coreDataObject.lastTimeFed ?? .now
        self.lastTimePlayed = coreDataObject.lastTimePlayed ?? .now
        self.id = Int(coreDataObject.id)
        self.normalImageData = coreDataObject.normalImageData ?? Data()
        self.lieImageData = coreDataObject.lieImageData ?? Data()
        self.sitImageData = coreDataObject.sitImageData ?? Data()
        var imagesData = [PixelPalAction: [Data]]()
        if let actions = coreDataObject.actionData {
            for action in actions.allObjects as! [TamagochiActionData] {
                if let pixelPalAction = PixelPalAction(rawValue: action.action ?? "") {
                    var imagesDataFromCoreData = [Data]()
                    if let images = action.images {
                        for imageObject in images {
                            if let imageObject = imageObject as? TamagochiImage, let imageData = imageObject.image {
                                imagesDataFromCoreData.append(imageData)
                            }
                        }
                    }
                    imagesData[pixelPalAction] = imagesDataFromCoreData
                }
            }
        }
        self.imagesData = imagesData
        let minDate = min(lastTimeFed, lastTimePlayed)
        let minutesLeft = Date.now.minutes(from: minDate)
        if minutesLeft > constants.inactiveMinutes {
            addHealth(-minutesLeft / constants.inactiveMinutes)
        }
    }
    
    // MARK: - Methods
    
    mutating func addWeight(_ value: Double) {
        weight += value
        if weight < .zero {
            weight = .zero
        }
    }
    
    mutating func updateLastTimeFed(with newValue: Date) {
        lastTimeFed = newValue
        saveLastTimeFed()
    }
    
    mutating func updateLastTimePlayed(with newValue: Date) {
        lastTimePlayed = newValue
        saveLastTimePlayed()
    }
    
    mutating func addToScrolledEogether(_ value: Double) {
        scrolledEogether += value
        CoreDataHelper.getCoreData().updateScrolledEogether(id: self.id, newValue: scrolledEogether)
    }
    
    mutating func updateScrolledEogether(from value: Double) {
        self.scrolledEogether = value
        CoreDataHelper.getCoreData().updateScrolledEogether(id: self.id, newValue: value)
    }
    
    mutating func addHealth(_ value: Int) {
        let newHealth = health + value
        if newHealth > TamagochiObjectConstants.maxHealth {
            updateHealth(TamagochiObjectConstants.maxHealth)
        } else if newHealth < .zero {
            updateHealth(.zero)
        } else {
            updateHealth(newHealth)
        }
    }
    
    mutating func updateHealth(_ newValue: Int) {
        self.health = newValue
        saveHealth()
    }
    
    mutating func setHealth(_ newValue: Int) {
        self.health = newValue
    }
    
    mutating func updateName(with newValue: String) {
        name = newValue
        CoreDataHelper.getCoreData().updateName(id: self.id, newName: newValue)
    }
    
    private func saveHealth() {
        CoreDataHelper.getCoreData().updateHealth(id: self.id, newHealth: self.health)
    }
    
    private func saveLastTimeFed() {
        CoreDataHelper.getCoreData().updateLastTimeFed(id: self.id, newValue: self.lastTimeFed)
    }
    
    private func saveLastTimePlayed() {
        CoreDataHelper.getCoreData().updateLastTimePlayed(id: self.id, newValue: self.lastTimePlayed)
    }
}

// MARK: - Constants

struct TamagochiObjectConstants {
    static let defaultHealth = 1
    static let maxHealth = 6
    static let inactiveMinutes = 8
}
