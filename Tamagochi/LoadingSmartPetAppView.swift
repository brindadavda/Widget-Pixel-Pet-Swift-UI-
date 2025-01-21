//
//  LoadingSmartPetAppView.swift
//  Tamagochi
//
//  Created by Tim Akhmetov on 12.08.2024.
//


import SwiftUI

//
fileprivate var loadingSmartPetAppView = "LoadingSmartPetAppView"
//

struct LoadingSmartPetAppView: View {
    
    @EnvironmentObject private var myPetViewModel: TamagochiViewModel
    @EnvironmentObject private var myPetSettingsViewModel: SmartPetSettingsViewModel
    @EnvironmentObject private var widgetRectanglesViewModel: TamagochiViewModel
    
    @StateObject var networkMonitor = NetworkStateMonitorConnector()
    
    @State var isActive = false
    @State var rotate = 0.0
    @State var displayValue = 0
    private let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    
    
    
    var body: some View {
        if self.displayValue > 110 {
            MainView_TamagochiVVV()
                .environmentObject(self.myPetSettingsViewModel)
                .environmentObject(self.myPetViewModel)
                .environmentObject(self.widgetRectanglesViewModel)
                .environmentObject(networkMonitor)
                .preferredColorScheme(.dark)
            //                            .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .identity))
            
        }else {
            
            GeometryReader { geo in
                ZStack {
                    
                    Color(.BG)
                        .ignoresSafeArea()
                    
                    
                    
                    VStack {
                        
                        Image(.heartFill)
                            .resizable()
                            .scaledToFit()
                            .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? geo.size.width * 0.4 : geo.size.width * 0.3)
                        
                        numValueForStartSimpleLoading(displayValue: displayValue)
                            .onReceive(timer, perform: { _ in
                                if displayValue < 120 {
                                    withAnimation {
                                        self.displayValue += 1
                                    }
                                    
                                }
                            })
                            .frame(width: geo.size.width * 0.9)
                        
                        ZStack(alignment: .leading) {
                            
                            
                            Rectangle()
                                .fill(Color.init(hex: "FFED4C"))
                                .frame(width: self.displayValue < 100 ? geo.size.width * 0.9 / 100 * CGFloat(self.displayValue) : geo.size.width * 0.9)
                                .animation(.easeInOut, value: self.displayValue)
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 1)
                                .fill(Color.black)
                            
                            
                        }
                        .frame(width: geo.size.width * 0.9, height: UIDevice.current.userInterfaceIdiom == .phone ? 50 : 100)
                        .cornerRadius(10)
                    }
                }
            }
            
        }
        
    }
}

struct numValueForStartSimpleLoading: View {
    var displayValue: Int
    var body: some View {
        
        HStack {
            
            Text("Loading...")
                .font(
                    Font.custom("DM Sans", size: UIDevice.current.userInterfaceIdiom == .phone ? 25 : 35)
                )
                .foregroundColor(Color.black)
                .animation(.none, value: displayValue)
            
            Spacer()
            
            Text(displayValue < 100 ? "\(displayValue)%" : "100%")
                .font(
                    Font.custom("DM Sans", size: UIDevice.current.userInterfaceIdiom == .phone ? 32 : 45)
                )
                .foregroundColor(Color.black)
                .animation(.none, value: displayValue)
            
        }
    }
}

#Preview(body: {
    LoadingSmartPetAppView()
})
