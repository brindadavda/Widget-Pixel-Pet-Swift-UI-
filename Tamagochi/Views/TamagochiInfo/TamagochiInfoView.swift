//
//  TamagochiInfoView.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI

struct TamagochiInfoView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var tamagochiViewModel: TamagochiViewModel
    
    @Binding var selectedNav: EntertainmentType
    @Binding var showDetail: Bool
    @Binding var showSelf: Bool
    @Binding var presentedViews: [EntertainmentType]
    
    @State private var minSide = 0.0
    @State private var alertType = AlertType_TamagochiVVV.heartInfo
    @State private var showAlert = false
    @State private var catName = ""
    
    // MARK: - Body
    
    var body: some View {
        makeUI()
    }
    
    // MARK: - UI
    
    private func makeUI() -> some View {
        GeometryReader { geo in
            NavigationStack(path: $presentedViews) {
                VStack {
                    VStack(spacing: 0) {
                        makeTopView(with: geo)
                        makeMiddleView()
                        makeBottomView()
                    }
                    .navigationDestination(for: EntertainmentType.self, destination: { selectedNav in
                        switch selectedNav {
                        case .food:
                            FeedView(isShown: $showDetail, showAlert: $showAlert, alertType: $alertType, presentedViews: $presentedViews)
                                .padding([.leading, .trailing], UIDevice.current.userInterfaceIdiom == .phone ? 16 : minSide / 2.5)
                                .background {
                                    BackgroundClearView()
                                        .ignoresSafeArea()
                                        .onTapGesture {
                                            withAnimation {
                                                showSelf = false
                                            }
                                        }
                                }
                        case .play:
                            VStack {
                                GameView(isShown: $showDetail, presentedViews: $presentedViews)
                                    .frame(height: geo.size.height - geo.size.height * 0.1)
                                Spacer()
                            }
                            .padding([.leading, .trailing], UIDevice.current.userInterfaceIdiom == .phone ? 16 : minSide / 2.5)
                            .background {
                                BackgroundClearView()
                                    .ignoresSafeArea()
                                    .onTapGesture {
                                        withAnimation {
                                            showSelf = false
                                        }
                                    }
                            }
                        }
                    })
                    .alert(alertType.getTitle(with: tamagochiViewModel.tamagochiLogic.currentTamagochi.name), isPresented: $showAlert, actions: {
                        makeAlertView()
                    }, message: {
                        Text(alertType.getMessage(with: alertType == .renameError ? catName : tamagochiViewModel.tamagochiLogic.currentTamagochi.name))
                    })
                    .padding(.all, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 28)
                    .foregroundColor(.white)
                    .rectangleBackground(with: Color(red: 0, green: 0.27, blue: 1), backgroundColor: Color(red: 0, green: 0.27, blue: 1).opacity(0.2), cornerRadius: UIDevice.current.userInterfaceIdiom == .phone ? 12 : 16)
                    .background {
                        Color.black
                            .cornerRadius(UIDevice.current.userInterfaceIdiom == .phone ? 12 : 16)
                    }
                    .padding([.leading, .trailing], UIDevice.current.userInterfaceIdiom == .phone ? 16 : 65)
                    .frame(width: geo.size.width, height: geo.size.height - geo.size.height * 0.1)
                    .cornerRadius(UIDevice.current.userInterfaceIdiom == .phone ? 12 : 16)
                    Spacer()
                }
                .background {
                    BackgroundClearView()
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showSelf = false
                            }
                        }
                }
                .opacity(showDetail ? 0 : 1)
                .animation(.easeInOut, value: showDetail)
            }
            .frame(maxWidth: geo.size.width, maxHeight: geo.size.height)
            .font(
                Font.custom("DM Sans", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24)
                    .weight(.medium)
            )
            .background {
                BackgroundClearView()
                    .ignoresSafeArea()
            }
            .cornerRadius(UIDevice.current.userInterfaceIdiom == .phone ? 12 : 16)
            .onAppear {
                catName = tamagochiViewModel.tamagochiLogic.currentTamagochi.name
                minSide = min(geo.size.width, geo.size.height)
            }
        }
    }
    
    @ViewBuilder
    private func makeAlertView() -> some View {
        switch alertType {
        case .heartInfo, .renameError, .feedingInfo, .feedingError:
            Button("OK", role: .cancel, action: {
                showAlert = false
                catName = tamagochiViewModel.tamagochiLogic.currentTamagochi.name
            })
        case .rename:
            TextField("Pixel Pal Name", text: $catName)
                .foregroundColor(.white)
            Button("Cancel", role: .cancel, action: {
                showAlert = false
            })
            Button("Rename", action: {
                if catName.isEmpty || catName.containsOnlySpaces() || catName.count > 10 {
                    alertType = .renameError
                    Task {
                        await Task.sleep(seconds: 0.1)
                        showAlert = true
                    }
                }
                else {
                    withAnimation {
                        tamagochiViewModel.updateName(with: catName)
                    }
                }
            })
        default:
            EmptyView()
        }
    }
    
    private func makeBottomView() -> some View {
        Button(action: {
            alertType = .heartInfo
            showAlert = true
        }, label: {
            HStack(spacing: 15) {
                let currentHealth = tamagochiViewModel.tamagochiLogic.currentTamagochi.health
                if currentHealth > .zero {
                    ForEach(0..<currentHealth, id: \.self, content: { _ in
                        Image("heartFill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: minSide * 0.08, height: minSide * 0.08)
                    })
                }
                if currentHealth != 6 {
                    ForEach(currentHealth..<6, id: \.self, content: { _ in
                        Image("heartEmpty")
                            .resizable()
                            .scaledToFit()
                            .frame(width: minSide * 0.08, height: minSide * 0.08)
                    })
                }
            }
        })
        .padding(.top, UIDevice.current.userInterfaceIdiom == .phone ? 30 : 42)
    }
    
    @ViewBuilder
    private func makeMiddleView() -> some View {
        makeValueView(with: "age", title: "Age", and: tamagochiViewModel.tamagochiLogic.currentTamagochi.creationDate.ageString())
            .padding(.top, UIDevice.current.userInterfaceIdiom == .phone ? 30 : 42)
        makeValueView(with: "weight", title: "Weight", and: "\(String(format: "%.2f", tamagochiViewModel.tamagochiLogic.currentTamagochi.weight)) lbs")
            .padding([.top, .bottom], UIDevice.current.userInterfaceIdiom == .phone ? 10 : 14)
        makeValueView(with: "scroll", title: "Scrolled Eogether", and: "\(String(format: "%.2f", tamagochiViewModel.tamagochiLogic.currentTamagochi.scrolledEogether)) km")
    }
    
    private func makeValueView(with imageName: String, title: String, and value: String) -> some View {
        HStack {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? minSide * 0.07 : minSide * 0.06, height: UIDevice.current.userInterfaceIdiom == .phone ? minSide * 0.07 : minSide * 0.06)
                .rectangleBackground(with: Color(red: 0, green: 0.27, blue: 1), backgroundColor: .white.opacity(0.2), cornerRadius: 12)
                .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? minSide * 0.13 : minSide * 0.1, height: UIDevice.current.userInterfaceIdiom == .phone ? minSide * 0.13 : minSide * 0.1)
            Text(title)
                .padding(.leading, UIDevice.current.userInterfaceIdiom == .phone ? 4 : 8)
            Spacer()
            Text(value)
        }
    }
    
    private func makeTopView(with geo: GeometryProxy) -> some View {
        HStack {
            let data = tamagochiViewModel.tamagochiLogic.currentTamagochi.sitImageData
            if let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: geo.size.height / 12)
                    .zIndex(1)
            }
            makeNameButton()
                .padding(.leading, UIDevice.current.userInterfaceIdiom == .phone ? 4 : 8)
            Spacer()
            Group {
                makeFeedButton()
                makePlayButton()
            }
            .frame(width:  UIDevice.current.userInterfaceIdiom == .phone ? geo.size.width * 0.16 : geo.size.width * 0.13)
        }
        .frame(height: geo.size.height * 0.1)
    }
    
    private func makeNameButton() -> some View {
        Button(action: {
            alertType = .rename
            showAlert = true
        }, label: {
            HStack {
                Text(tamagochiViewModel.tamagochiLogic.currentTamagochi.name)
                    .minimumScaleFactor(0.2)
                Image("pencil")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 14 : 20, height: UIDevice.current.userInterfaceIdiom == .phone ? 14 : 20)
            }
        })
    }
    
    private func makeFeedButton() -> some View {
        Button(action: {
            selectedNav = .food
            presentedViews.append(selectedNav)
            showDetail = true
        }, label: {
            Text("Feed")
                .foregroundColor(.yellow)
                .rectangleBackground(with: .yellow, backgroundColor: .clear, cornerRadius: UIDevice.current.userInterfaceIdiom == .phone ? 8 : 12)
        })
    }
    
    private func makePlayButton() -> some View {
        Button(action: {
            selectedNav = .play
            presentedViews.append(selectedNav)
            showDetail = true
        }, label: {
            Text("Play")
                .foregroundColor(.red)
                .rectangleBackground(with: .red, backgroundColor: .clear, cornerRadius: UIDevice.current.userInterfaceIdiom == .phone ? 8 : 12)
        })
    }
    
}

// MARK: - Preview

struct TamagochiInfoView_Previews: PreviewProvider {
    static var previews: some View {
        TamagochiInfoView(selectedNav: .constant(.food), showDetail: .constant(false), showSelf: .constant(true), presentedViews: .constant([]))
            .environmentObject(TamagochiViewModel())
            .frame(width: 300, height: 250)
    }
}
