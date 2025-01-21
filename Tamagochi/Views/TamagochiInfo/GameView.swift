//
//  GameView.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI

struct GameView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var tamagochiViewModel: TamagochiViewModel
    
    @State private var minSide = 0.0
    @State private var selectedInteraction = TamagochiInteractions.none
    @State private var showGame = false
    @State private var showWand = false
    
    @Binding var isShown: Bool
    @Binding var presentedViews: [EntertainmentType]
    
    // MARK: - Body
    
    var body: some View {
        makeUI()
    }
    
    // MARK: - UI
    
    private func makeUI() -> some View {
        GeometryReader { geo in
            VStack {
                makeTopView()
                makeMiddleView()
                Spacer()
                makeBottomView()
                Spacer()
            }
            .opacity(!isShown ? 0 : 1)
            .animation(.easeInOut, value: isShown)
            .toolbar(.hidden)
            .fullScreenCover(isPresented: $showWand, content: {
                WandView(isShown: $showWand)
            })
            .onChange(of: showWand, perform: { _ in
                withAnimation {
                    tamagochiViewModel.togglePlayingWithWand()
                }
            })
            .onChange(of: showGame, perform: { newValue in
                if newValue {
                    withAnimation {
                        tamagochiViewModel.togglePlayingWithBall()
                    }
                    showGame = false
                }
            })
            .foregroundColor(.white)
            .onAppear {
                minSide = min(geo.size.width, geo.size.height)
            }
            .rectangleBackground(with: Color(red: 0, green: 0.27, blue: 1), backgroundColor: Color(red: 0, green: 0.27, blue: 1).opacity(0.2), cornerRadius: 12)
            .background {
                Color.black
                    .cornerRadius(UIDevice.current.userInterfaceIdiom == .phone ? 12 : 16)
            }
        }
        .background {
            BackgroundClearView()
                .ignoresSafeArea()
        }
    }
    
    private func makeTopView() -> some View {
        HStack {
            Button(action: {
                if let index = presentedViews.firstIndex(of: .play) {
                    presentedViews.remove(at: index)
                }
                isShown = false
            }, label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .scaledToFit()
                    .font(.system(size: minSide / 15))
            })
            Spacer()
            Text("Choose Game")
            Spacer()
        }
        .padding([.leading, .trailing], UIDevice.current.userInterfaceIdiom == .phone ? 20 : 40)
        .padding(.top, UIDevice.current.userInterfaceIdiom == .phone ? 40 : 20)
    }
    
    private func makeMiddleView() -> some View {
        Text("Engaging in games with \(tamagochiViewModel.tamagochiLogic.currentTamagochi.name) gradually raises affection levels.")
            .multilineTextAlignment(.center)
            .foregroundColor(.gray)
            .padding([.leading, .trailing])
            .frame(maxHeight: .infinity)
            .font(
                Font.custom("DM Sans", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 18)
                    .weight(.medium)
            )
    }
    
    private func makeBottomView() -> some View {
        Group {
            MainMenuNavButton(imageName: "ball", title: "Beacon Ball", subTitle: "", destination: .ball, titleFontSize: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 24, cornerRadius: minSide * 0.025, backgroundColor: .clear, selectedNav: $selectedInteraction, showDetail: $showGame)
                .padding([.top, .leading, .trailing])
            MainMenuNavButton(imageName: "wand", title: "Follow the Wand", subTitle: "", destination: .wand, titleFontSize: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 24, cornerRadius: minSide * 0.025, backgroundColor: .clear, selectedNav: $selectedInteraction, showDetail: $showWand)
                .padding([.bottom, .leading, .trailing])
        }
        .disabled(tamagochiViewModel.currentInteraction != .none)
    }
    
}

// MARK: - Preview

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(isShown: .constant(true), presentedViews: .constant([]))
            .environmentObject(TamagochiViewModel())
    }
}
