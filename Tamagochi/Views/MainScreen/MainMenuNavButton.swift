//
//  MainMenuNavButton.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI

struct MainMenuNavButton<T: RawRepresentable>: View where T.RawValue == String {
    
    // MARK: - Properties
    
    var needRectangle: Bool = true
    var imageName: String
    var title: String
    var subTitle: String
    var destination: T
    var titleFontSize: Double? = nil
    var cornerRadius: Double
    var backgroundColor: Color = Color(red: 0, green: 0.27, blue: 1).opacity(0.2)
    
    @Binding var selectedNav: T
    @Binding var showDetail: Bool
    
    // MARK: - Body
    
    var body: some View {
        makeUI()
    }
    
    // MARK: - UI
    
    private func makeUI() -> some View {
        GeometryReader { geo in
            let minSide = min(geo.size.width, geo.size.height)
            Button(action: {
                selectedNav = destination
                showDetail = true
            }, label: {
                ZStack {
                    HStack(spacing: 0) {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: geo.size.height * 0.5)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8))
                        VStack(alignment: .leading, spacing: 0) {
                            Text(title)
                                .font(Font.custom("DM Sans", size: titleFontSize ?? (UIDevice.current.userInterfaceIdiom == .phone ? 16 : 18)))
                            if !subTitle.isEmpty {
                                Text(subTitle)
                                    .font(Font.custom("DM Sans", size: (UIDevice.current.userInterfaceIdiom == .phone ? 14 : 16)))
                                    .padding(.zero)
                            }
                        }
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.2)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? geo.size.width * 0.07 : geo.size.width * 0.04, height: geo.size.height * (!subTitle.isEmpty  ? 0.16 : 0.25))
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .foregroundColor(.white)
                    }
                    .padding(.all, 16)
                }
                .contentShape(Rectangle())
            })
            .buttonStyle(PlainButtonStyle())
            .frame(width: geo.size.width, height: geo.size.height)
            .rectangleBackground(with: Color(red: 0, green: 0.27, blue: 1), backgroundColor: backgroundColor, cornerRadius: cornerRadius, shouldApply: needRectangle)
        }
    }
    
}

// MARK: - Preview

struct MainMenuNavButton_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuNavButton(
            imageName: "palm",
            title: "Title",
            subTitle: "Subtitle",
            destination: NavigationDestination.widgetInstruction,
            cornerRadius: 15, selectedNav: .constant(.widgetInstruction),
            showDetail: .constant(true))
            .frame(width: 350, height: 200)
    }
}
