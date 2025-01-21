//
//  TamagochiApp.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI

@main
struct TamagochiApp: App {
    
    private var settingsViewModel = SmartPetSettingsViewModel(isForWidget: false)
    private var tamagochiViewModel = TamagochiViewModel()
    private var widgetsViewModel = WidgetsViewModel()
    
    var body: some Scene {
        WindowGroup {
            VStack {
                LoadingSmartPetAppView() //MainView_TamagochiVVV()
                    .environmentObject(settingsViewModel)
                    .environmentObject(tamagochiViewModel)
                    .environmentObject(widgetsViewModel)
                    .preferredColorScheme(.dark)
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .identity))
            }
            .task {
                await Task.sleep(seconds: 1)
            }
        }
    }
}
