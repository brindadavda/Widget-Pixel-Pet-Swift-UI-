//
//  PreviewData.swift
//  Tamagochi
//
//  Created by Systems
//

import Foundation

// struct, that represents info about cat animation
struct PreviewData: Equatable {
    
    // MARK: - Properties
    
    private(set) var pixelPalAction: PixelPalAction
    private(set) var images: [Data]
    private(set) var currentAnimalIndex = 0
    private(set) var offsetForAnimation = CGPoint.zero
    private(set) var minValues = CGPoint.zero
    private(set) var maxValues = CGPoint.zero
    private(set) var isXReversed = false
    private(set) var isYReversed = false
    
    private let onlyX: Bool
    
    // MARK: - Inits
    
    init(pixelPalAction: PixelPalAction, images: [Data], onlyX: Bool = false) {
        self.pixelPalAction = pixelPalAction
        self.images = images
        self.onlyX = onlyX
    }
    
    // MARK: - Methods
    
    mutating func updateReverseX(with newValue: Bool) {
        isXReversed = newValue
    }
    
    mutating func updateReverseY(with newValue: Bool) {
        isYReversed = newValue
    }
    
    mutating func updateState(with action: PixelPalAction, and newImages: [Data]) {
        currentAnimalIndex = 0
        pixelPalAction = action
        images = newImages
    }
    
    mutating func updateCurrentAnimalIndex() {
        if currentAnimalIndex != images.count - 1 {
            currentAnimalIndex += 1
        }
        else {
            currentAnimalIndex = 0
        }
    }
    
    mutating func updateMaxValues(with newValue: CGPoint) {
        maxValues = newValue
    }
    
    mutating func updateMinValues(with newValue: CGPoint) {
        minValues = newValue
    }
    
    mutating func updateXOffset() {
        var inset = isXReversed ? -5.0 : 5.0
        if offsetForAnimation.x + inset > maxValues.x {
            isXReversed = true
            inset = -(offsetForAnimation.x - maxValues.x)
            if !onlyX {
                updateYOffset()
            }
        }
        if offsetForAnimation.x + inset < minValues.x {
            isXReversed = false
            inset = minValues.x - offsetForAnimation.x
            if !onlyX {
                updateYOffset()
            }
        }
        offsetForAnimation = CGPoint(x: offsetForAnimation.x + inset, y: offsetForAnimation.y)
    }
    
    private mutating func updateYOffset() {
        var inset = isYReversed ? -15.0 : 15.0
        if offsetForAnimation.y + inset > maxValues.y {
            isYReversed = true
            inset = -(offsetForAnimation.y - maxValues.y)
        }
        if offsetForAnimation.y + inset < minValues.y {
            isYReversed = false
            inset = minValues.y - offsetForAnimation.y
        }
        offsetForAnimation = CGPoint(x: offsetForAnimation.x, y: offsetForAnimation.y + inset)
    }
    
    mutating func updateOffset(with newValue: CGPoint) {
        offsetForAnimation = newValue
    }
    
    mutating func updateImages(with newValue: [Data]) {
        images = newValue
    }
    
}
