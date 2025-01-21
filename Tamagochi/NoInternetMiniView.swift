//
//  NoInternetMiniView.swift
//  Tamagochi
//
//  Created by Tim Akhmetov on 12.08.2024.
//


import SwiftUI

//
fileprivate var noInternetMiniView = "NoInternetMiniView"
//
//
fileprivate var dopNoInternetMiniView = "dopNoInternetMiniView"
//

struct NoInternetMiniView: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var networkMonitor: NetworkStateMonitorConnector
    @Binding var isConnected: Bool
    
    var body: some View {
        
        GeometryReader { geo in
            ZStack {
                Color.init(hex: "FEFFE5")
                    .ignoresSafeArea()
                
                VStack {
                    
                    Image(.noInetLogo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIDevice.current.userInterfaceIdiom == .phone  ? geo.size.width * 0.2 : geo.size.width * 0.15)
                    
                    Text("No Internet connection")
                        .foregroundStyle(Color.black)
                        .font(Font.custom("DM Sans", size: UIDevice.current.userInterfaceIdiom == .phone ? 22 : 40))
                    
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    
                    Button {
                        isConnected = true
                        
                    } label: {
                        Text("OK")
                            .foregroundStyle(Color.black)
                            .font(Font.custom("DM Sans", size: UIDevice.current.userInterfaceIdiom == .phone ? 13 : 32))
                    }
                    .customCornerStrokeRectangleBackground(with: Color.black, backgroundColor: Color.init(hex: "FFED4C"), cornerRadius: 10)
                    .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? geo.size.width * 0.18 : geo.size.width * 0.15, height: UIDevice.current.userInterfaceIdiom == .phone ? geo.size.width * 0.11 : geo.size.width * 0.08)
                }
                
            }
        }
        .navigationBarBackButtonHidden()
    }
    

}


#Preview(body: {
    NoInternetMiniView(isConnected: .constant(false))
})

extension View {
    func customCornerStrokeRectangleBackground(with strokeColor: Color, backgroundColor: Color, cornerRadius: Double, shouldApply: Bool = true, isGradient: Bool = false) -> some View {
        return self.modifier(SpecialRectangleSimpleBackgroundToViews(strokeColor: strokeColor, backgroundColor: backgroundColor, shouldApply: shouldApply, cornerRadius: cornerRadius, isGradient: isGradient))
     
    }
}

struct SpecialRectangleSimpleBackgroundToViews: ViewModifier {
    
    let strokeColor: Color
    let backgroundColor: Color
    let shouldApply: Bool
    let cornerRadius: Double
    let isGradient: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            Color.clear
                .opacity(1)
            Color.clear
                .opacity(1)
            if shouldApply {
                ZStack {
                    if isGradient {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .inset(by: 0.5)
                            .stroke(strokeColor, lineWidth : 1)
                            .background(Gradient(stops: [Gradient.Stop(color: backgroundColor, location: 0.0), Gradient.Stop(color: Color.init(hex: "#A6FC9F"), location: 0.99)]))
                    }else {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .inset(by: 0.5)
                            .stroke(strokeColor, lineWidth : 1)
                            .background(backgroundColor)
                    }
                    content
                }
                .cornerRadius(cornerRadius)
            }
            else {
                content
            }
        }
    }
    
}
