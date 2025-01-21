//
//  HSWidgetsView.swift
//  Tamagochi
//
//  Created by Systems
//

import PhotosUI
import SwiftUI

struct HSWidgetsView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var settingsViewModel: SmartPetSettingsViewModel
    
    @State private var minSide = 0.0
    @State private var photosPickerPresented = false
    @State private var selectedImage: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var showAlert = false
    @State private var imageName = ""
    @State private var alertType = AlertType_TamagochiVVV.photoName
    @State private var loadedImages = [String: UIImage]()
    
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
                if !settingsViewModel.availablePhotos.isEmpty {
                    makeList(with: geo)
                }
            }
            .onChange(of: imageName) { _ in
                if imageName.count > 14 {
                    selectedImage = nil
                    alertType = .renameError
                    showAlert = false
                    Task {
                        await Task.sleep(seconds: 0.1)
                        showAlert = true
                    }
                }
            }
            .padding(EdgeInsets(top: 26, leading: DesignConstants.defaultEdgeDistance, bottom: 0, trailing: DesignConstants.defaultEdgeDistance))
            .alert(alertType.getTitle(), isPresented: $showAlert, actions: {
                makeAlertView(with: geo)
            }, message: {
                Text(alertType.getMessage(with: imageName, maximumCharacters: 14, and: 3))
            })
            .preferredColorScheme(.dark)
            .task(id: selectedImage, {
                do {
                    selectedImageData = try await selectedImage?.loadTransferable(type: Data.self)
                    if selectedImageData != nil {
                        imageName = ""
                        alertType = .photoName
                        showAlert = true
                    }
                }
                catch {
                    print(error.localizedDescription)
                }
            })
            .photosPicker(isPresented: $photosPickerPresented, selection: $selectedImage, matching: .images)
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
            .minimumScaleFactor(0.2)
            .onAppear {
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
    
    @ViewBuilder
    private func makeTopView(with geo: GeometryProxy) -> some View {
        makeInstructionView(with: "To Add", and: "1.  Tap “Choose Image” below.", minSide: minSide)
            .frame(height: UIDevice.current.userInterfaceIdiom == .phone ? geo.size.height * 0.18 : geo.size.height * 0.12)
        makeInstructionView(with: "To Use", and: "1.  Long-press Home Screen to jiggle. 2. Tap on “Widget” Widget. 3. Set “Background” to “Custom Photo”. 4. Tap the new “Photo” menu, and choose your photo!", minSide: minSide)
            .frame(height: UIDevice.current.userInterfaceIdiom == .phone ? geo.size.height * 0.35 : geo.size.height * 0.2)
            .padding(EdgeInsets(top: 24, leading: 0, bottom: 0, trailing: 0))
        Button(action: {
            photosPickerPresented = true
        }, label: {
            HStack(spacing: 12) {
                Image("chooseImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                Text("Choose Image")
                    .font(
                        Font.custom("DM Sans", size: UIDevice.current.userInterfaceIdiom == .phone ? 14 : 18)
                            .weight(.bold)
                    )
                    .lineLimit(1)
            }
            .padding(.leading, 12)
            .padding(.trailing, 12)
        })
        .rectangleBackground(with: Color(red: 0, green: 0.27, blue: 1), backgroundColor: Color(red: 0, green: 0.27, blue: 1).opacity(0.2), cornerRadius: 12)
        .frame(width: geo.size.width * 0.4, height: UIDevice.current.userInterfaceIdiom == .phone ? geo.size.height * 0.08 : geo.size.height * 0.06)
        .padding(EdgeInsets(top: 24, leading: 0, bottom: 24, trailing: 0))
    }
    
    private func makeList(with geo: GeometryProxy) -> some View {
        List {
            Section {
                ForEach(settingsViewModel.availablePhotos, content: { photoInfo in
                    VStack {
                        if let uiImage = loadedImages[photoInfo.id] {
                            ZStack {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 100)
                                    .clipped()
                                    .cornerRadius(12)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 12)
                                            .inset(by: 0.5)
                                            .stroke(Color(red: 0, green: 0.27, blue: 1), lineWidth : 3)
                                    }
                                Color("BGColor").opacity(0.3)
                                    .cornerRadius(12)
                                Text(photoInfo.id)
                                    .font(
                                        Font.custom("DM Sans", size: minSide / 20)
                                            .weight(.bold)
                                    )
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .minimumScaleFactor(0.2)
                            }
                        }
                        else {
                            makeProgressView()
                                .onAppear {
                                    generatePreview(of: SmartPetSettingsViewModel.PhotoInfo(id: photoInfo.id, data: photoInfo.data), with: geo.size)
                                }
                        }
                    }
                })
                .onDelete(perform: settingsViewModel.deletePhoto)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(PlainListStyle())
        .scrollContentBackground(.hidden)
        .background {
            Color("BGColor")
                .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private func makeAlertView(with geo: GeometryProxy) -> some View {
        if alertType == .photoName {
            TextField("Photo Name", text: $imageName)
                .foregroundColor(.white)
            Button("Add", action: {
                if imageName.isEmpty || imageName.containsOnlySpaces() || imageName.count > 14 || imageName.count < 3 {
                    selectedImage = nil
                    alertType = .renameError
                    Task {
                        await Task.sleep(seconds: 0.1)
                        showAlert = true
                    }
                } else if settingsViewModel.photoNames.contains(imageName) {
                    alertType = .samePhotoName
                    Task {
                        await Task.sleep(seconds: 0.1)
                        showAlert = true
                    }
                } else {
                    if let selectedImageData, let image = UIImage(data: selectedImageData)?.resized(toWidth: 300), let imageData = image.pngData() {
                        withAnimation {
                            settingsViewModel.savePhoto(imageData, with: imageName)
                            generatePreview(of: SmartPetSettingsViewModel.PhotoInfo(id: imageName, data: selectedImageData), with: geo.size)
                            selectedImage = nil
                        }
                    }
                }
            })
            Button(alertType == .renameError ? "OK" : "Cancel", role: .cancel, action: {
                alertType = .photoName
            })
        } else if alertType == .samePhotoName {
            Button("Yes", role: .none, action: {
                alertType = .photoName
                if let selectedImageData, let image = UIImage(data: selectedImageData)?.resized(toWidth: 300), let imageData = image.pngData() {
                    withAnimation {
                        settingsViewModel.savePhoto(imageData, with: imageName)
                        generatePreview(of: SmartPetSettingsViewModel.PhotoInfo(id: imageName, data: selectedImageData), with: geo.size)
                        selectedImage = nil
                    }
                }
            })
            Button("No", role: .cancel, action: {
                selectedImage = nil
                alertType = .photoName
            })
        } else {
            Button(alertType == .renameError ? "OK" : "Cancel", role: .cancel, action: {
                selectedImage = nil
                alertType = .photoName
            })
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
            Text("Home Screen Widget")
                .font(
                    Font.custom("DM Sans", size: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 28)
                        .weight(.medium)
                )
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            EditButton()
                .font(
                    Font.custom("DM Sans", size: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 28)
                        .weight(.medium)
                )
                .padding(.trailing, UIDevice.current.userInterfaceIdiom == .pad ? 45 : 0)
        }
    }
    
    private func makeProgressView() -> some View {
        ProgressView()
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .inset(by: 0.5)
                    .stroke(Color(red: 0, green: 0.27, blue: 1), lineWidth : 3)
            }
    }
    
    private func generatePreview(of imageInfo: SmartPetSettingsViewModel.PhotoInfo, with size: CGSize) {
        if let image = UIImage(data: imageInfo.data) {
            Task.detached {
                let previewImage = await image.byPreparingThumbnail(ofSize: size)
                await MainActor.run {
                    withAnimation {
                        loadedImages[imageInfo.id] = previewImage
                    }
                }
            }
        }
    }
    
}

// MARK: - Preview

struct HSWidgetsView_Previews: PreviewProvider {
    static var previews: some View {
        HSWidgetsView(isShown: .constant(true))
    }
}
