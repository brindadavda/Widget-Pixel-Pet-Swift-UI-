//
//  IntentHandler.swift
//  WidgetIntentExt
//
//  Created by Systems
//

import Intents

class MyPetIntentHandler: INExtension, ConfigurationIntentHandling {
    
    private let settingViewModel = SmartPetSettingsViewModel(isForWidget: true)
    
    func resolveTextColor(for intent: ConfigurationIntent) async -> TextColorResolutionResult {
        .success(with: .black)
    }
    
    func resolveFontStyle(for intent: ConfigurationIntent) async -> FontStyleResolutionResult {
        .success(with: .normal)
    }
    
    func resolveHexCode(for intent: ConfigurationIntent) async -> INStringResolutionResult {
        .success(with: "Bla")
    }
    
    func resolvePhoto(for intent: ConfigurationIntent) async -> PhotoResolutionResult {
        .success(with: Photo(identifier: "Bla", display: "Bla"))
    }
    
    func resolveBigPal(for intent: ConfigurationIntent) async -> INBooleanResolutionResult {
        .success(with: true)
    }
    
    func resolveActionType(for intent: ConfigurationIntent) async -> ActionResolutionResult {
        .success(with: .sleep)
    }
    
    func resolveBackground(for intent: ConfigurationIntent) async -> BackgroundResolutionResult {
        .success(with: .default)
    }
    func resolvePixelPal(for intent: ConfigurationIntent) async -> AnimalsResolutionResult {
        .success(with: .luna)
    }
    
    func resolveInfoBackground(for intent: ConfigurationIntent) async -> InfoBackgroundResolutionResult {
        .success(with: InfoBackground(identifier: "Clock Text", display: "Clock Text"))
    }
    
    func provideInfoBackgroundOptionsCollection(for intent: ConfigurationIntent) async throws -> INObjectCollection<InfoBackground> {
        var settings = [InfoBackground]()
        for widget in settingViewModel.availableWidgets {
            settings.append(InfoBackground(identifier: widget.rawValue.camelCaseToHumanReadable(), display: widget.rawValue.camelCaseToHumanReadable()))
        }
        let collection = INObjectCollection(items: settings)
        return collection
    }
    
    func providePhotoOptionsCollection(for intent: ConfigurationIntent) async throws -> INObjectCollection<Photo> {
        var photos = [Photo]()
        for availablePhoto in settingViewModel.photoNames {
            photos.append(Photo(identifier: availablePhoto, display: availablePhoto))
        }
        let collection = INObjectCollection(items: photos)
        return collection
    }
//    
//    func provideInfoBackgroundOptionsCollection(for intent: ConfigurationIntent) async throws -> INObjectCollection<InfoBackground> {
//        var settings = [InfoBackground]()
//        for widget in settingViewModel.availableWidgets {
//            settings.append(InfoBackground(identifier: widget.rawValue.camelCaseToHumanReadable(), display: widget.rawValue.camelCaseToHumanReadable()))
//        }
//        let collection = INObjectCollection(items: settings)
//        return collection
//    }
//    
//    func providePhotoOptionsCollection(for intent: ConfigurationIntent) async throws -> INObjectCollection<Photo> {
//        var photos = [Photo]()
//        for availablePhoto in settingViewModel.photoNames {
//            photos.append(Photo(identifier: availablePhoto, display: availablePhoto))
//        }
//        let collection = INObjectCollection(items: photos)
//        return collection
//    }
    
}
