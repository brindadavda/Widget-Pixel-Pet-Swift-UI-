//
//  FeedView.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI

struct FeedView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var tamagochiViewModel: TamagochiViewModel
    
    @State private var minSide = 0.0
    
    @Binding var isShown: Bool
    @Binding var showAlert: Bool
    @Binding var alertType: AlertType_TamagochiVVV
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
                Spacer()
                makeFoodView(with: geo)
                Spacer()
            }
            .opacity(!isShown ? 0 : 1)
            .animation(.easeInOut, value: isShown)
            .foregroundColor(.white)
            .onAppear {
                minSide = min(geo.size.width, geo.size.height)
            }
            .toolbar(.hidden)
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
                if let index = presentedViews.firstIndex(of: .food) {
                    presentedViews.remove(at: index)
                }
                isShown = false
            }, label: {
                Image(systemName: "chevron.left")
                    .resizable()
                    .foregroundColor(.white)
                    .scaledToFit()
                    .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 28, height: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 28)
            })
            Spacer()
            Text("Feed \(tamagochiViewModel.tamagochiLogic.currentTamagochi.name)")
            Spacer()
            Button(action: {
                alertType = .feedingInfo
                showAlert = true
            }, label: {
                Image("info")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 28, height: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 28)
            })
        }
        .padding([.leading, .trailing], UIDevice.current.userInterfaceIdiom == .phone ? 20 : 40)
        .padding(.top, UIDevice.current.userInterfaceIdiom == .phone ? 40 : 20)
    }
    
    private func makeFoodView(with geo: GeometryProxy) -> some View {
        LazyVGrid(columns: [GridItem(.flexible(minimum: 10)), GridItem(.flexible(minimum: 10)), GridItem(.flexible(minimum: 10))], spacing: 32, content: {
            ForEach(Food.allCases, content: { food in
                Button(action: {
                    if Date.now.minutes(from: tamagochiViewModel.lastTimeFed) > 5 {
                        tamagochiViewModel.toggleFeedWith(food: food)
                    }
                    else {
                        showAlert = true
                        alertType = .feedingError
                    }
                }, label: {
                    VStack {
                        Image(food.rawValue)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.height / 12)
                        Text(food.rawValue.capitalizeFirstLetter())
                            .font(
                                Font.custom("DM Sans", size: UIDevice.current.userInterfaceIdiom == .phone ? 14 : 16)
                                    .weight(.medium)
                            )
                    }
                })
                .frame(width: geo.size.width / 3)
                .disabled(tamagochiViewModel.currentInteraction != .none)
                .buttonStyle(PlainButtonStyle())
            })
        })
        .padding(.all, 20)
    }
    
}

// MARK: - Preview

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView(isShown: .constant(true), showAlert: .constant(false), alertType: .constant(.feedingInfo), presentedViews: .constant([]))
            .environmentObject(TamagochiViewModel())
    }
}
