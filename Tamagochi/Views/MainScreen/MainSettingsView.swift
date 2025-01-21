//
//  MainSettingsView.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI
import WidgetKit

struct MainSettingsView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var settingsViewModel: SmartPetSettingsViewModel
    
    @State private var minSide = 0.0
    @State private var selectedNav = NavigationDestination.widgetInstruction
    @State private var showDetail = false
    @State private var showAlert = false
    
    @Binding var isShown: Bool
    
    // MARK: - Body
    
    var body: some View {
        makeUI()
    }
    
    // MARK: - UI
    
    private func makeUI() -> some View {
        GeometryReader { geo in
            VStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 8 : 16) {
                makeFirstRow()
                makeActionRow()
                MainMenuNavButton(imageName: "widgetInstruction", title: "Widget Instructions", subTitle: "", destination: .widgetInstruction, titleFontSize: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 18, cornerRadius: 12, selectedNav: $selectedNav, showDetail: $showDetail)
                    .frame(height: 56)
            }
            .padding(EdgeInsets(top: 26, leading: DesignConstants.defaultEdgeDistance, bottom: 0, trailing: DesignConstants.defaultEdgeDistance))
            .onChange(of: settingsViewModel.temperatureUnit, perform: { _ in
                WidgetCenter.shared.reloadAllTimelines()
            })
            .onChange(of: settingsViewModel.userLocation, perform: { _ in
                WidgetCenter.shared.reloadAllTimelines()
            })
            .alert("Error", isPresented: $showAlert, actions: {
                Button("OK", action: {
                    withAnimation {
                        showAlert = false
                    }
                })
            }, message: {
                Text("Allow access to use your location in settings!")
            })
            .onAppear {
                minSide = min(geo.size.width, geo.size.height)
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                makeToolbar()
            }
            .navigationDestination(isPresented: $showDetail, destination: {
                WidgetInstructionView(isShown: $showDetail)
            })
        }
        .background {
            Color("BGColor")
                .ignoresSafeArea()
        }
        .ignoresSafeArea(.keyboard, edges: .all)
    }
    
    @ToolbarContentBuilder
    private func makeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: {
                isShown = false
            }, label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .scaledToFit()
                    .font(.system(size: 24))
            })
            .padding(.leading, UIDevice.current.userInterfaceIdiom == .pad ? 45 : 0)
        }
        ToolbarItem(placement: .principal) {
            Text("Settings")
                .font(
                    Font.custom("DM Sans", size: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 28)
                        .weight(.medium)
                )
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
        }
    }
    
    private func makeActionRow() -> some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                Image("temperatureUnit")
                    .resizable()
                    .scaledToFit()
                    .frame(height: geo.size.height * 0.5)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8))
                Text("Temperature Unit")
                    .lineLimit(1)
                    .font(Font.custom("DM Sans", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 18))
                Spacer()
                Menu(settingsViewModel.temperatureUnit.rawValue.capitalizeFirstLetter()) {
                    Button(action: {
                        settingsViewModel.temperatureUnit = .celsius
                    }, label: {
                        Text(TemperatureUnit.celsius.rawValue.capitalizeFirstLetter())
                    })
                    Button(action: {
                        settingsViewModel.temperatureUnit = .fahrenheit
                    }, label: {
                        Text(TemperatureUnit.fahrenheit.rawValue.capitalizeFirstLetter())
                    })
                }
                .preferredColorScheme(.dark)
                .foregroundColor(.gray)
                .lineLimit(1)
                .font(Font.custom("DM Sans", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 18))
                .id(UUID())
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8))
                VStack {
                    Image(systemName: "chevron.up")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                    Image(systemName: "chevron.down")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                }
                .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? geo.size.width * 0.07 : geo.size.width * 0.04, height: 24)
            }
            .padding(.all, 16)
            .frame(width: geo.size.width, height: 56)
            .rectangleBackground(with: Color(red: 0, green: 0.27, blue: 1), backgroundColor: Color(red: 0, green: 0.27, blue: 1).opacity(0.2), cornerRadius: 12)
        }
        .frame(height: 56)
    }
    
    private func makeFirstRow() -> some View {
        GeometryReader { geo in
            ZStack {
                Button(action: {
                    withAnimation {
                        if settingsViewModel.status != .denied {
                            settingsViewModel.requestLocation()
                        }
                        else {
                            showAlert = true
                        }
                    }
                }, label: {
                    ZStack {
                        HStack(spacing: 0) {
                            Image("rain")
                                .resizable()
                                .scaledToFit()
                                .frame(height: geo.size.height * 0.5)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8))
                            Group {
                                Text("Set Weather Location")
                                    .lineLimit(1)
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8))
                                Spacer()
                                Text(settingsViewModel.currentCity)
                                    .foregroundColor(.gray)
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8))
                            }
                            .font(Font.custom("DM Sans", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 18))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .minimumScaleFactor(0.2)
                            Image(systemName: "chevron.right")
                                .resizable()
                                .scaledToFit()
                                .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? geo.size.width * 0.07 : geo.size.width * 0.04, height: geo.size.height * 0.25)
                                .foregroundColor(.white)
                        }
                        .padding(.all, 16)
                    }
                })
                .buttonStyle(PlainButtonStyle())
                if settingsViewModel.requestingCity {
                    Color(red: 0, green: 0.27, blue: 1).opacity(0.5)
                    ProgressView()
                        .foregroundColor(.white)
                }
            }
            .frame(width: geo.size.width, height: 56)
            .rectangleBackground(with: Color(red: 0, green: 0.27, blue: 1), backgroundColor: Color(red: 0, green: 0.27, blue: 1).opacity(0.2), cornerRadius: 12)
            .allowsHitTesting(!settingsViewModel.requestingCity)
            .cornerRadius(12)
        }
        .frame(height: 56)
    }
    
}

// MARK: - Preview

struct MainSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        MainSettingsView(isShown: .constant(true))
            .environmentObject(SmartPetSettingsViewModel(isForWidget: false))
    }
}
