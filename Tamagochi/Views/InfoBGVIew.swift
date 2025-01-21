//
//  InfoBGVIew.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI
import WidgetKit

struct InfoBGVIew: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var widgetViewModel: WidgetsViewModel
    @EnvironmentObject private var settingsViewModel: SmartPetSettingsViewModel
    
    @State private var minSide = 0.0
    @State private var animalImages = [WidgetType_TamagochiVVV: [UIImage]]()
    @State private var widgetPhotos = [WidgetType_TamagochiVVV: UIImage]()
    @State private var showAlert = false
    @State private var showDatePicker = false
    @State private var alertType = AlertType_TamagochiVVV.eventAlert
    @State private var event = String()
    @State private var eventDate = Date.now
    
    @Binding var isShown: Bool
    
    // MARK: - Body
    
    var body: some View {
        makeUI()
    }
    
    // MARK: - UI
    
    private func makeUI() -> some View {
        GeometryReader { geo in
            VStack {
                makeTopView(with: geo)
                makeMiddleView()
                makeBottomView(with: geo)
                    .padding(EdgeInsets(top: 0, leading: DesignConstants.defaultEdgeDistance, bottom: 0, trailing: DesignConstants.defaultEdgeDistance))
            }
            .onChange(of: event) { _ in
                if event.count > 30 {
                    alertType = .eventError
                    showAlert = false
                    Task {
                        await Task.sleep(seconds: 0.1)
                        showAlert = true
                    }
                }
            }
            .task {
                let tempData = try? await settingsViewModel.getWeather()
                if let tempData, !tempData.isEmpty {
                    widgetViewModel.updateTempData(with: tempData)
                }
            }
            .sheet(isPresented: $showDatePicker, onDismiss: {
                event = String()
                eventDate = .now
            }, content: {
                makeDatePickerView(with: geo)
            })
            .alert(alertType.getTitle(), isPresented: $showAlert, actions: {
                getAlertView()
            }) {
                Text(alertType.getMessage(with: event))
            }
            .onAppear {
                widgetViewModel.generatePreviewData()
                for widgetType in WidgetType_TamagochiVVV.allCases {
                    if let widgetPhotoData = settingsViewModel.availableWidgetBGs.randomElement()?.data {
                        widgetPhotos[widgetType] = UIImage(data: widgetPhotoData)
                    }
                    if let tamagochiesImagesData = widgetViewModel.previewData[widgetType] {
                        var tamagochiImages = [UIImage]()
                        for data in tamagochiesImagesData.images {
                            if let tamagochiImage = UIImage(data: data) {
                                tamagochiImages.append(tamagochiImage)
                            }
                        }
                        animalImages[widgetType] = tamagochiImages
                    }
                }
                minSide = min(geo.size.width, geo.size.height)
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                makeToolbar()
            }
        }
        .background {
            Color("BGColor")
                .ignoresSafeArea()
        }
        .ignoresSafeArea(.keyboard, edges: .all)
    }
    
    private func makeDatePickerView(with geo: GeometryProxy) -> some View {
        VStack {
            makeWidgetTextView(with: "Choose event date")
                .padding([.top, .leading, .trailing])
            DatePicker(
                "Event Date",
                selection: $eventDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .padding([.top, .leading, .trailing])
            Button(action: {
                withAnimation {
                    showDatePicker = false
                    Task {
                        await Task.sleep(seconds: 0.1)
                        showAlert = true
                    }
                    alertType = .widgetAdded
                    widgetViewModel.updateCurrentEvent(with: eventDate, and: event)
                }
                event = String()
                eventDate = .now
            }, label: {
                makeWidgetTextView(with: "Save")
                    .rectangleBackground(with: Color(red: 0, green: 0.27, blue: 1), backgroundColor: Color(red: 0, green: 0.27, blue: 1).opacity(0.3), cornerRadius: 12)
            })
            .contentShape(Rectangle())
            .padding([.top, .bottom])
            .frame(width: geo.size.width * 0.25, height: geo.size.width * 0.2)
        }
        .background {
            Color.clear.background(.ultraThinMaterial)
                .ignoresSafeArea()
                .frame(width: geo.size.width, height: geo.size.height * 2)
        }
        .background(
            BackgroundClearView()
                .ignoresSafeArea()
        )
    }
    
    @ViewBuilder
    private func getAlertView() -> some View {
        if alertType != .eventAlert {
            Button("OK", role: .cancel, action: {
                event = String()
                WidgetCenter.shared.reloadAllTimelines()
                showAlert = false
            })
        } else {
            TextField("Event", text: $event)
                .foregroundColor(.white)
            Button("Cancel", role: .cancel, action: {
                event = String()
                showAlert = false
            })
            Button("Next", action: {
                if event.isEmpty || event.containsOnlySpaces() || event.count > 30 {
                    alertType = .eventError
                    Task {
                        await Task.sleep(seconds: 0.1)
                        showAlert = true
                    }
                }
                else {
                    showAlert = false
                    showDatePicker = true
                }
            })
        }
    }
    
    @ViewBuilder
    private func makeTopView(with geo: GeometryProxy) -> some View {
        SegmentControl_TamagochiVVV(data: [SegmentControl_TamagochiVVV.Data_TamagochiVVV(image: Image("smallRect"), text: "Small", type: .small), SegmentControl_TamagochiVVV.Data_TamagochiVVV(image: Image("mediumRect"), text: "Medium", type: .medium)], selectedValue: $widgetViewModel.selectedSize)
            .frame(height: 56)
            .padding(EdgeInsets(top: 26, leading: DesignConstants.defaultEdgeDistance, bottom: 0, trailing: DesignConstants.defaultEdgeDistance))
        SegmentControl_TamagochiVVV(data: [SegmentControl_TamagochiVVV.Data_TamagochiVVV(image: nil, text: "Normal", type: .normal), SegmentControl_TamagochiVVV.Data_TamagochiVVV(image: nil, text: "Serif", type: .serif), SegmentControl_TamagochiVVV.Data_TamagochiVVV(image: nil, text: "Handwritten", type: .handwritten)], selectedValue: $widgetViewModel.selectedTextStyle)
            .frame(height: 40)
            .padding(EdgeInsets(top: 12, leading: DesignConstants.defaultEdgeDistance, bottom: 0, trailing: DesignConstants.defaultEdgeDistance))
    }
    
    private func makeMiddleView() -> some View {
        ZStack(alignment: .bottom) {
            Image("infoBG")
                .resizable()
            ScrollView(.vertical) {
                LazyVGrid(columns: [GridItem(.flexible(minimum: minSide / 4, maximum: minSide / 1.1))], spacing: 50, content: {
                    ForEach(WidgetType_TamagochiVVV.allCases, content: { value in
                        VStack {
                            if widgetViewModel.widgetData.selectedSize == .small {
                                makeWidgetView(for: value)
                                    .transition(.scale)
                                    .scaledToFit()
                                    .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .phone ? minSide / 2 : minSide / 4)
                                    .overlay {
                                        VStack {
                                            Spacer()
                                            getWidgetButtons(for: value)
                                        }
                                    }
                            } else {
                                makeWidgetView(for: value)
                                    .transition(.scale)
                                    .aspectRatio(2/1, contentMode: .fit)
                                    .overlay {
                                        VStack {
                                            Spacer()
                                            getWidgetButtons(for: value)
                                        }
                                    }
                            }
                            makeWidgetTextView(with: value.rawValue.camelCaseToHumanReadable())
                        }
                        .frame(maxHeight: UIDevice.current.userInterfaceIdiom == .phone ? minSide / 2 : minSide / 4)
                    })
                })
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
            }
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        widgetViewModel.updateColor()
                    }
                }, label: {
                    Image("changeColor")
                        .foregroundColor(.black)
                        .scaleEffect(0.25)
                        .frame(height: UIDevice.current.userInterfaceIdiom == .phone ? minSide / 8 : minSide / 12)
                        .background(Circle().foregroundColor(widgetViewModel.widgetData.bgColor.color))
                        .shadow(color: Color.black, radius: 10, x: 5, y: 5)
                })
            }
            .opacity(widgetViewModel.widgetData.bgStyle == .color ? 1 : 0)
            .padding(.trailing, UIDevice.current.userInterfaceIdiom == .pad ? 65 : 20)
            .padding(.bottom, UIDevice.current.userInterfaceIdiom == .pad ? 40 : 20)
        }
        .ignoresSafeArea()
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
    }
    
    private func getWidgetButtons(for widgetType: WidgetType_TamagochiVVV) -> some View {
        HStack {
            Spacer()
            if widgetType == .event {
                Button(action: {
                    withAnimation {
                        showAlert = true
                        alertType = .eventAlert
                    }
                }, label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.black, .blue)
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .phone ? minSide / 11 : minSide / 22))
                })
            }
        }
    }
    
    @ViewBuilder
    private func makeBottomView(with geo: GeometryProxy) -> some View {
        Text("Preview Background as....")
            .font(
                Font.custom("DM Sans", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 18)
                    .weight(.medium)
            )
            .multilineTextAlignment(.center)
            .foregroundColor(.white)
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
        SegmentControl_TamagochiVVV(data: [SegmentControl_TamagochiVVV.Data_TamagochiVVV(image: nil, text: "Transparent", type: .transparent), SegmentControl_TamagochiVVV.Data_TamagochiVVV(image: nil, text: "Photo", type: .photo), SegmentControl_TamagochiVVV.Data_TamagochiVVV(image: nil, text: "Color", type: .color)], selectedValue: $widgetViewModel.selectedBGStyle)
            .frame(height: 40)
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
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
    }
    
    private func makeWidgetTextView(with text: String) -> some View {
        Text(text)
            .font(
                Font.custom("SF Pro Text", size: 14)
                    .weight(.bold)
            )
            .multilineTextAlignment(.center)
            .foregroundColor(.white)
    }
    
    @ViewBuilder
    private func makeWidgetView(for widgetType: WidgetType_TamagochiVVV) -> some View {
        makeWidgetView(for: widgetType, with: animalImages[widgetType] ?? [UIImage(named: "cat_1_normal")!], and: widgetPhotos[widgetType] ?? UIImage(named: "cat_1_normal")!)
            .environmentObject(widgetViewModel)
    }
    
}

// MARK: - Preview

struct InfoBGVIew_Previews: PreviewProvider {
    static var previews: some View {
        InfoBGVIew(isShown: .constant(true))
            .environmentObject(SmartPetSettingsViewModel(isForWidget: false))
            .environmentObject(WidgetsViewModel())
    }
}
