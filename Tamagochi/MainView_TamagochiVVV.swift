//
//  MainView_TamagochiVVV.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI
import CoreHaptics
import WidgetKit

struct MainView_TamagochiVVV: View {
    
    // MARK: - Properties
    
    @Environment(\.scenePhase) private var scenePhase
    
    @EnvironmentObject private var widgetViewModel: WidgetsViewModel
    @EnvironmentObject private var tamagochiViewModel: TamagochiViewModel
    @EnvironmentObject private var settingsViewModel: SmartPetSettingsViewModel
    @EnvironmentObject var networkMonitor: NetworkStateMonitorConnector
    
    @State private var isDynamicIsland = UIDevice.current.hasDynamicIsland
    @State private var selectedCat = 1
    @State private var selectedNav = NavigationDestination.dynamicIsland
    @State private var showDetail = false
    // for cats animation
    @State private var secondRow = 0
    // minSide of the screen
    @State private var minSide = 0.0
    @State private var showTamagochiInfo = false
    @State private var hapticEngine: CHHapticEngine?
    @State private var selectedInfoNav: EntertainmentType = .food
    @State private var showInfoDetail: Bool = false
    @State private var presentedInfoViews = [EntertainmentType]()
    @State private var isInteractionLocked = false
    
    @State private var isConneted = true
    @State private var isStarted = false
    
    @Namespace private var selectedCatNamespace
    
    // MARK: - Body
    
    var body: some View {
        if isConneted {
            makeUI()
            .gesture(DragGesture())
            .onAppear {
                if !isStarted {
                    self.isConneted = networkMonitor.isConnected
                }
                isStarted = true
            }
        }else {
            NoInternetMiniView(isConnected: $isConneted)
                .environmentObject(networkMonitor)
        }
    }
    
    // MARK: - UI
    
    private func makeUI() -> some View {
        GeometryReader { geo in
            NavigationStack {
                makeList(with: geo)
                    .navigationBarTitleDisplayMode(.inline)
            }
            .onOpenURL { incomingURL in
                print("App was opened via URL: \(incomingURL)")
                handleIncomingURL(incomingURL)
            }
            .onChange(of: scenePhase) { newScenePhase in
                switch newScenePhase {
                case .active:
                    print("App is active")
                case .inactive:
                    settingsViewModel.startBGTask()
                case .background:
                    settingsViewModel.startBGTask()
                @unknown default:
                    print("Interesting: Unexpected new value.")
                }
            }
            .onStatusBarTap(with: geo) {
                withAnimation {
                    showTamagochiInfo = true
                }
            }
            .onAppear {
                WidgetCenter.shared.reloadAllTimelines()
                isDynamicIsland = UIDevice.current.hasDynamicIsland
                let multiplierForAnimation = isDynamicIsland ? 0.12 : 0.15
                setupHapticEngine()
                selectedCat = Int(tamagochiViewModel.tamagochiLogic.currentTamagochi.id)
                minSide = min(geo.size.width, geo.size.height)
                tamagochiViewModel.updateMaxValuesForAnimation(with: CGPoint(x: geo.size.width * multiplierForAnimation, y: 0))
                tamagochiViewModel.updateMinValuesForAnimation(with: CGPoint(x: -geo.size.width * multiplierForAnimation, y: 0))
                settingsViewModel.setAllTamagochies(tamagochiViewModel.allTamagochies)
                if settingsViewModel.alwaysShowPixelPal {
                    settingsViewModel.setActivity()
                }
            }
            .overlay(
                VStack {
                    if !UIDevice.current.hasPhysicalButton {
                        if isDynamicIsland {
                            getMainCatView(with: geo)
                                .offset(y: -103.5)
                        }
                        if showTamagochiInfo {
                            TamagochiInfoView(selectedNav: $selectedInfoNav, showDetail: $showInfoDetail, showSelf: $showTamagochiInfo, presentedViews: $presentedInfoViews)
                                .padding(EdgeInsets(top: UIDevice.current.userInterfaceIdiom == .phone ? 50 : 75, leading: 10, bottom: 0, trailing: 10))
                                .frame(height: UIDevice.current.userInterfaceIdiom == .phone ? geo.size.height * 0.6 : geo.size.height * 0.42)
                                .zIndex(-1)
                                .background {
                                    if tamagochiViewModel.currentInteraction != .wand {
                                        Color.black
                                            .opacity(0.5)
                                            .ignoresSafeArea()
                                            .frame(width: geo.size.width, height: geo.size.height * 3)
                                            .onTapGesture {
                                                withAnimation {
                                                    showTamagochiInfo = false
                                                }
                                            }
                                    }
                                }
                        }
                        Spacer()
                        if !isDynamicIsland {
                            getMainCatView(with: geo)
                        }
                    }
                }
            )
        }
        .ignoresSafeArea(.keyboard, edges: .all)
    }
    
    private func getMainCatView(with geo: GeometryProxy) -> some View {
        ZStack {
            let currentInteraction = tamagochiViewModel.currentInteraction
            if currentInteraction == .ball || currentInteraction == .feeding {
                getObjectView()
            }
            getCatView()
        }
        .background {
            if tamagochiViewModel.currentInteraction == .wand {
                Color(red: 0.08, green: 0.16, blue: 0.36).opacity(0.71).background(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .frame(width: geo.size.width, height: geo.size.height * 3)
            }
        }
    }
    
    private func getCatView() -> some View {
        
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        let isRTL = Locale.Language(identifier: languageCode).characterDirection == .rightToLeft
        
        return ZStack {
            if let uiImage = UIImage(data: tamagochiViewModel.currentImageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(x: (isRTL ? -1 : 1) * (tamagochiViewModel.isXReversed ? -1 : 1), y: 1)
                    .frame(width: isDynamicIsland ? 12 : UIDevice.current.userInterfaceIdiom == .phone ? minSide * 0.05 : minSide * 0.03, height: isDynamicIsland ? 12 : UIDevice.current.userInterfaceIdiom == .phone ? minSide * 0.05 : minSide * 0.03)
                    .offset(y: getBottomYOffset())
            }
        }
        .frame(width: minSide * 0.1, height: minSide * 0.1)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                showTamagochiInfo = true
            }
        }
        .offset(x: tamagochiViewModel.offsetForAnimation.x, y: 0)
    }
    
    private func getObjectView() -> some View {
        Image(uiImage: getObjectImage())
            .resizable()
            .scaledToFit()
            .frame(width: isDynamicIsland ? 12 : UIDevice.current.userInterfaceIdiom == .phone ? minSide * 0.05 : minSide * 0.03, height: isDynamicIsland ? 12 : UIDevice.current.userInterfaceIdiom == .phone ? minSide * 0.05 : minSide * 0.03)
            .rotationEffect(.degrees(tamagochiViewModel.currentInteraction == .ball ? tamagochiViewModel.rotationOfBall : 0), anchor: .center)
            .offset(x: tamagochiViewModel.offsetForObject.x, y: tamagochiViewModel.offsetForObject.y + 30)
            .transition(.asymmetric(insertion: .identity, removal: tamagochiViewModel.currentInteraction == .ball ? .move(edge: .bottom) : .identity))
            .animation(.easeInOut(duration: 0.4), value: tamagochiViewModel.offsetForObject)
            .onChange(of: tamagochiViewModel.endedPlayingWithBall, perform: { newValue in
                playVibration()
                if newValue {
                    withAnimation {
                        tamagochiViewModel.togglePlayingWithBall()
                    }
                }
            })
            .onChange(of: tamagochiViewModel.eatedHalf, perform: { newValue in
                playVibration()
                if !newValue {
                    withAnimation {
                        tamagochiViewModel.toggleFeedWith(food: .apple)
                    }
                }
            })
            .onChange(of: tamagochiViewModel.offsetForObject, perform: { newValue in
                if newValue.y == .zero {
                    playVibration()
                }
            })
    }
    
    private func getBottomYOffset() -> CGFloat {
        switch tamagochiViewModel.currentAction  {
        case .crouch, .sleep:
            return UIDevice.current.userInterfaceIdiom == .phone ? 33 : 40
        case .run, .chill:
            return UIDevice.current.userInterfaceIdiom == .phone ? 31 : 38
        }
    }
    
    private func makeList(with geo: GeometryProxy) -> some View {
        List {
            Group {
                makeFirstSection(with: geo)
                if UIDevice.current.hasDynamicIsland {
                    makeSecondSection(with: geo)
                } else {
                    makeThirdSection(with: geo)
                }
                makeFourthSection(with: geo)
            }
            .disabled(showTamagochiInfo)
        }
        .clipped()
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarBackground(Color("BGColor"), for: .navigationBar)
        .navigationDestination(isPresented: $showDetail, destination: {
            switch selectedNav {
            case .dynamicIsland:
                AdditionalSettingsView(isLiveActivity: false, isShown: $showDetail)
            case .liveActivity:
                AdditionalSettingsView(isLiveActivity: true, isShown: $showDetail)
            case .widgetInstruction:
                WidgetInstructionView(isShown: $showDetail)
            case .transperentBG:
                TransperentBGView(isShown: $showDetail)
            case .widgetsBG:
                HSWidgetsView(isShown: $showDetail)
            case .mainSettings:
                MainSettingsView(isShown: $showDetail)
            case .infoBG:
                InfoBGVIew(isShown: $showDetail)
            }
        })
        .listStyle(PlainListStyle())
        .scrollContentBackground(.hidden)
        .background {
            Color("BGColor")
                .ignoresSafeArea()
        }
        .toolbar {
            makeToolbar()
        }
    }
    
    private func makeFirstSection(with geo: GeometryProxy) -> some View {
        Section {
            VStack {
                makeTopView(with: geo)
                makeCatsGrid()
            }
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 26, leading: DesignConstants.defaultEdgeDistance, bottom: 0, trailing: DesignConstants.defaultEdgeDistance))
        .listRowBackground(Color.clear)
    }
    
    private func makeSecondSection(with geo: GeometryProxy) -> some View {
        Section {
            MainMenuNavButton(
                imageName: "palm",
                title: "Dynamic Island",
                subTitle: "Take your Pal everywhere",
                destination: .dynamicIsland,
                cornerRadius: 12, selectedNav: $selectedNav,
                showDetail: $showDetail)
            .frame(height: UIDevice.current.userInterfaceIdiom == .phone ? 73 : 78)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 25, leading: DesignConstants.defaultEdgeDistance, bottom: 25, trailing: DesignConstants.defaultEdgeDistance))
        .listRowBackground(Color.clear)
    }
    
    private func makeThirdSection(with geo: GeometryProxy) -> some View {
        Section {
            MainMenuNavButton(
                imageName: "lightning",
                title: "Live Activities",
                subTitle: "Pin to lock screen bottom",
                destination: .liveActivity,
                cornerRadius: 12, selectedNav: $selectedNav,
                showDetail: $showDetail)
            .frame(height: UIDevice.current.userInterfaceIdiom == .phone ? 73 : 78)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: DesignConstants.defaultEdgeDistance, bottom: 24, trailing: DesignConstants.defaultEdgeDistance))
        .listRowBackground(Color.clear)
    }
    
    private func makeFourthSection(with geo: GeometryProxy) -> some View {
        Section {
            VStack {
                MainMenuNavButton(
                    needRectangle: false,
                    imageName: "info",
                    title: "Widget Instructions",
                    subTitle: "How to set up a widget",
                    destination: .widgetInstruction,
                    cornerRadius: 12, selectedNav: $selectedNav,
                    showDetail: $showDetail)
                .frame(height: UIDevice.current.userInterfaceIdiom == .phone ? 73 : 78)
                makeLineView()
                MainMenuNavButton(
                    needRectangle: false,
                    imageName: "transperent",
                    title: "Transparent Background",
                    subTitle: "Make your widget see-through",
                    destination: .transperentBG,
                    cornerRadius: 12, selectedNav: $selectedNav,
                    showDetail: $showDetail)
                .frame(height: UIDevice.current.userInterfaceIdiom == .phone ? 73 : 78)
                makeLineView()
                MainMenuNavButton(
                    needRectangle: false,
                    imageName: "photo",
                    title: "Photo Background",
                    subTitle: "Loved one, vacation, an acorn...",
                    destination: .widgetsBG,
                    cornerRadius: 12, selectedNav: $selectedNav,
                    showDetail: $showDetail)
                .frame(height: UIDevice.current.userInterfaceIdiom == .phone ? 73 : 78)
            }
            .rectangleBackground(with: Color(red: 0, green: 0.27, blue: 1), backgroundColor: Color(red: 0, green: 0.27, blue: 1).opacity(0.2), cornerRadius: 12)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: DesignConstants.defaultEdgeDistance, bottom: 0, trailing: DesignConstants.defaultEdgeDistance))
        .listRowBackground(Color.clear)
    }
    
    private func makeTopView(with geo: GeometryProxy) -> some View {
        VStack(alignment: .leading) {
            Color.clear
                .background {
                    Image("topMainImage")
                        .resizable()
                        .scaledToFill()
                }
                .clipped()
            Text("Info Backgrounds!")
                .font(Font.custom("DM Sans", size: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 24))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .minimumScaleFactor(0.2)
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))
            Text("Add weather, battery, calendar, clocks, countdowns and more to your widget!")
                .multilineTextAlignment(.leading)
                .font(Font.custom("DM Sans", size: UIDevice.current.userInterfaceIdiom == .phone ? 14 : 18))
                .foregroundColor(.gray)
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16))
                .minimumScaleFactor(0.2)
        }
        .rectangleBackground(with: Color(red: 0, green: 0.27, blue: 1), backgroundColor: Color(red: 0, green: 0.27, blue: 1).opacity(0.3), cornerRadius: 16)
        .frame(height: UIDevice.current.userInterfaceIdiom == .phone ? geo.size.height * 0.3 : geo.size.height * 0.25)
        .onTapGesture {
            selectedNav = .infoBG
            showDetail = true
        }
    }
    
    @ToolbarContentBuilder
    private func makeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: {
                selectedNav = .mainSettings
                showDetail = true
            }, label: {
                Image("gear")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24)
            })
            .padding(.leading, UIDevice.current.userInterfaceIdiom == .pad ? 45 : 0)
        }
        ToolbarItem(placement: .principal) {
            Text("Pixel Pals")
                .font(
                    Font.custom("DM Sans", size: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 28)
                        .weight(.medium)
                )
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
        }
    }
    
    private func makeCatsGrid() -> some View {
        LazyVGrid(columns: [GridItem(.flexible(minimum: 50)), GridItem(.flexible(minimum: 50)), GridItem(.flexible(minimum: 50)), GridItem(.flexible(minimum: 50))], spacing: 20, content: {
            ForEach(tamagochiViewModel.allTamagochies) { value in
                ZStack {
                    if selectedCat == value.id {
                        RoundedRectangle(cornerRadius: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 22.5)
                            .stroke(Color(red: 0, green: 0.27, blue: 1), lineWidth: 1)
                            .background(Color(red: 0, green: 0.27, blue: 1).opacity(0.2).cornerRadius(16))
                            .matchedGeometryEffect(id: "selectedCat", in: selectedCatNamespace)
                    }
                    if !value.imagesData.isEmpty {
                        if let uiImage = UIImage(data: value.normalImageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 30 : 74, height: UIDevice.current.userInterfaceIdiom == .phone ? 30 : 74)
                                .onTapGesture {
                                    if !isInteractionLocked {
                                        isInteractionLocked = true
                                        movingCatAnimation(with: Int(value.id))
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            isInteractionLocked = false
                                        }
                                    }
                                }
                                .animation(.none, value: selectedCat)
                                .animation(.none, value: tamagochiViewModel.tamagochiLogic.currentTamagochi)
                        }
                    }
                }
                .scaledToFit()
                .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 40 : 84, height: UIDevice.current.userInterfaceIdiom == .phone ? 40 : 84)
            }
        })
        .padding(EdgeInsets(top: 40, leading: 0, bottom: 40, trailing: 0))
    }
    
    private func movingCatAnimation(with value: Int) {
        var firstRow = value / 4
        secondRow = selectedCat / 4
        if value % 4 != 0 {
            firstRow += 1
        }
        if selectedCat % 4 != 0 {
            secondRow += 1
        }
        if firstRow == secondRow {
            withAnimation(Animation.easeInOut(duration: 0.25)) {
                selectedCat = value
                tamagochiViewModel.updateSelectedAnimal(with: selectedCat)
            }
        }
        else  {
            if value < selectedCat {
                Task {
                    withAnimation(Animation.easeInOut(duration: 0.1)) {
                        selectedCat -= 4
                        secondRow = selectedCat / 4
                        if selectedCat % 4 != 0 {
                            secondRow += 1
                        }
                    }
                    await Task.sleep(seconds: 0.07)
                    movingCatAnimation(with: value)
                }
            }
            else {
                Task {
                    withAnimation(Animation.easeInOut(duration: 0.1)) {
                        selectedCat += 4
                        secondRow = selectedCat / 4
                        if selectedCat % 4 != 0 {
                            secondRow += 1
                        }
                    }
                    await Task.sleep(seconds: 0.07)
                    movingCatAnimation(with: value)
                }
            }
        }
    }
    
    private func getObjectImage() -> UIImage {
        if tamagochiViewModel.currentInteraction == .ball {
            return UIImage(named: "ball")!
        }
        else if tamagochiViewModel.currentInteraction == .feeding {
            let foodImage =  UIImage(named: tamagochiViewModel.currentFood.rawValue)!
            if tamagochiViewModel.eatedHalf {
                return tamagochiViewModel.isXReversed ? foodImage.leftHalf! : foodImage.rightHalf!
            }
            else {
                return foodImage
            }
        }
        return UIImage(named: "ball")!
    }
    
    private func setupHapticEngine() {
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Error initializing haptic engine: \(error)")
        }
    }
    
    private func playVibration() {
        if let engine = hapticEngine {
            do {
                let pattern = try CHHapticPattern(events: [CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0)], parameters: [])
                let player = try engine.makePlayer(with: pattern)
                try player.start(atTime: 0)
            } catch {
                print("Error playing haptic feedback: \(error)")
            }
        }
    }
    
    private func handleIncomingURL(_ url: URL) {
        guard url.scheme == "tamagochiApp" else {
            return
        }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("Invalid URL")
            return
        }
        guard let action = components.host else {
            print("Unknown URL, we can't handle this one!")
            return
        }
        showTamagochiInfo = true
        if action == "open-feed" {
            selectedInfoNav = .food
            presentedInfoViews = [.food]
            showInfoDetail = true
        } else if action == "open-play" {
            selectedInfoNav = .play
            presentedInfoViews = [.play]
            showInfoDetail = true
        } else {
            presentedInfoViews = []
            showInfoDetail = false
        }
    }
    
}

// MARK: - Preview

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView_TamagochiVVV()
//            .environmentObject(TamagochiViewModel())
//            .environmentObject(WidgetsViewModel())
//            .environmentObject(SmartPetSettingsViewModel(isForWidget: false))
//    }
//}
