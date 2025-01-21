//
//  AdditionalSettingsView.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI

struct AdditionalSettingsView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var settingsViewModel: SmartPetSettingsViewModel
    
    var isLiveActivity: Bool
    
    @State private var minSide = 0.0
    
    @Binding var isShown: Bool
    
    // MARK: - Body
    
    var body: some View {
        makeUI()
    }
    
    // MARK: - UI
    
    private func makeUI() -> some View {
        GeometryReader { geo in
            VStack(spacing: 16) {
                if isLiveActivity {
                    makeView(with: geo, and: "Show Widget")
                } else {
                    makeView(with: geo, and: "Always Show Pixel Pal")
                }
            }
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            .onChange(of: settingsViewModel.alwaysShowPixelPal, perform: { newValue in
                if newValue {
                    settingsViewModel.setActivity()
                } else {
                    settingsViewModel.endActivity()
                }
            })
            .onChange(of: settingsViewModel.firstPixelPal, perform: { _ in
                settingsViewModel.restartActivity()
            })
            .onChange(of: settingsViewModel.secondPixelPal, perform: { _ in
                settingsViewModel.restartActivity()
            })
            .onChange(of: settingsViewModel.showSecondPixelPal, perform: { _ in
                settingsViewModel.restartActivity()
            })
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
            .minimumScaleFactor(1)
            .rectangleBackground(with: Color(red: 0, green: 0.27, blue: 1), backgroundColor: Color(red: 0, green: 0.27, blue: 1).opacity(0.2), cornerRadius: 12)
            .onAppear {
                minSide = min(geo.size.width, geo.size.height)
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                makeToolbar()
            }
            .frame(height: getHeight(with: geo))
            .animation(.easeInOut(duration: 0.5), value: settingsViewModel.alwaysShowPixelPal)
            .animation(.easeInOut(duration: 0.5), value: settingsViewModel.showSecondPixelPal)
            .padding(EdgeInsets(top: 26, leading: DesignConstants.defaultEdgeDistance, bottom: 0, trailing: DesignConstants.defaultEdgeDistance))
        }
        .background {
            Color("BGColor")
                .ignoresSafeArea()
        }
        .ignoresSafeArea(.keyboard, edges: .all)
    }
    
    @ViewBuilder
    private func makeView(with geo: GeometryProxy, and topTitle: String) -> some View {
        makeToggleView(with: topTitle, and: settingsViewModel.$alwaysShowPixelPal)
        if settingsViewModel.alwaysShowPixelPal {
            makeLineView(needPadding: false)
            makeActionRow(with: geo, title: "Pixel Pal", and: $settingsViewModel.firstPixelPal)
            makeLineView(needPadding: false)
            makeActionRow(with: geo, title: "Action", and: $settingsViewModel.pixelPalActionLA)
            makeLineView(needPadding: false)
            makeToggleView(with: "Show Second Pixel Pal", and: settingsViewModel.$showSecondPixelPal)
            if settingsViewModel.showSecondPixelPal {
                makeLineView(needPadding: false)
                makeActionRow(with: geo, title: "Second Pixel Pal", and: $settingsViewModel.secondPixelPal)
                makeLineView(needPadding: false)
                makeActionRow(with: geo, title: "Second Action", and: $settingsViewModel.secondPixelPalActionLA)
            }
        }
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
            Text(isLiveActivity ? "Live Activities" : "Dynamic Island")
                .font(
                    Font.custom("DM Sans", size: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 28)
                        .weight(.medium)
                )
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
        }
    }
    
    private func makeToggleView(with text: String, and state: Binding<Bool>) -> some View {
        Toggle(isOn: state, label: {
            Text(text)
                .lineLimit(1)
                .font(Font.custom("DM Sans", size: 18))
        })
        .controlSize(.large)
        .tint(Color(red: 0, green: 0.27, blue: 1))
    }
    
    private func makeActionRow<T: RawRepresentable & CaseIterable & Hashable>(with geo: GeometryProxy, title: String, and value: Binding<T>) -> some View where T.RawValue == String {
        HStack {
            Text(title)
                .lineLimit(1)
                .font(Font.custom("DM Sans", size: 18))
            Spacer()
            makeMenu(with: value)
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
            .frame(width: 24, height: 24)
        }
    }
    
    private func makeMenu<T: RawRepresentable & CaseIterable & Hashable>(with binding: Binding<T>) -> some View where T.RawValue == String {
        Menu(binding.wrappedValue.rawValue.capitalizeFirstLetter()) {
            ForEach(Array(T.allCases), id: \.self, content: { value in
                Button(action: {
                    binding.wrappedValue = value
                }, label: {
                    Text(value.rawValue.capitalizeFirstLetter())
                })
            })
        }
        .preferredColorScheme(.dark)
        .foregroundColor(.gray)
        .lineLimit(1)
        .font(Font.custom("DM Sans", size: 18))
    }
    
    private func getHeight(with geo: GeometryProxy) -> CGFloat {
        let specialFactor: CGFloat = UIDevice.current.hasPhysicalButton ? 30 : 0
        if settingsViewModel.alwaysShowPixelPal && settingsViewModel.showSecondPixelPal {
            return UIDevice.current.userInterfaceIdiom == .phone ? geo.size.height * 0.5 + specialFactor * 1.5 : geo.size.height * 0.33
        } else if settingsViewModel.alwaysShowPixelPal {
            return UIDevice.current.userInterfaceIdiom == .phone ? geo.size.height * 0.345 + specialFactor : geo.size.height * 0.22
        } else {
            return UIDevice.current.userInterfaceIdiom == .phone ? geo.size.height * 0.1 : geo.size.height * 0.05
        }
    }
    
}

// MARK: - Preview

struct DynamicIslandSettings_Previews: PreviewProvider {
    static var previews: some View {
        AdditionalSettingsView(isLiveActivity: false, isShown: .constant(false))
    }
}
