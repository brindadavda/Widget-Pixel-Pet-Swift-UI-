//
//  WandView.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI

struct WandView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var tamagochiViewModel: TamagochiViewModel
    
    @State private var minSide = 0.0
    @State private var offset = CGSize.zero
    @State private var currentOffset = CGSize.zero
    
    @Binding var isShown: Bool
    
    // MARK: - Body
    
    var body: some View {
        makeUI()
    }
    
    // MARK: - UI
    
    private func makeUI() -> some View {
        GeometryReader { geo in
            NavigationStack {
                VStack {
                    Spacer()
                    Text("Interact by moving the wand from side to side.")
                        .font(
                            Font.custom("DM Sans", size: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 40)
                                .weight(.medium)
                        )
                        .multilineTextAlignment(.center)
                        .padding([.leading, .trailing], UIDevice.current.userInterfaceIdiom == .phone ? 44 : minSide / 5)
                    Spacer()
                    makeWandView(with: geo)
                    Spacer()
                }
                .foregroundColor(.white)
                .onAppear {
                    minSide = min(geo.size.width, geo.size.height)
                }
                .toolbar {
                    makeToolbar()
                }
                .background(
                    BackgroundClearView()
                        .ignoresSafeArea()
                )
            }
            .background(
                BackgroundClearView()
                    .ignoresSafeArea()
            )
        }
    }
    
    private func makeWandView(with geo: GeometryProxy) -> some View {
        
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        let isRTL = Locale.Language(identifier: languageCode).characterDirection == .rightToLeft
        
        return Image("wand")
            .resizable()
            .scaledToFit()
            .frame(height: UIDevice.current.userInterfaceIdiom == .phone ? minSide / 8 : minSide / 12)
            .offset(CGSize(width: offset.width, height: 0))
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        let directionFactor: CGFloat = isRTL ? -1 : 1
                        let translationWidth = directionFactor * gesture.translation.width
                        let newValue = CGSize(width: currentOffset.width + translationWidth, height: currentOffset.height + gesture.translation.height)
                        if abs(newValue.width) < geo.size.width / 2 - 20 {
                            tamagochiViewModel.updateOffsetOfWand(with: offset)
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.5)) {
                                offset = newValue
                            }
                        }
                    }
                    .onEnded { gesture in
                        currentOffset = offset
                    }
            )
    }
    
    @ToolbarContentBuilder
    private func makeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {
                isShown = false
            }, label: {
                Text("Done")
                    .foregroundColor(Color(red: 0.52, green: 0.98, blue: 0.95))
            })
        }
    }
    
}

// MARK: - Preview

struct WandView_Previews: PreviewProvider {
    static var previews: some View {
        WandView(isShown: .constant(true))
            .environmentObject(TamagochiViewModel())
            .background(.red)
    }
}
