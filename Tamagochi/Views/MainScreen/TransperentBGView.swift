//
//  TransperentBGView.swift
//  Tamagochi
//
//  Created by Systems
//

import PhotosUI
import SwiftUI

struct TransperentBGView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var settingsViewModel: SmartPetSettingsViewModel
    
    @State private var minSide = 0.0
    @State private var photosPickerPresented = false
    @State private var selectedImage: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var previewImage: UIImage?
    @State private var isLoadingImage = false
    
    @Binding var isShown: Bool
    
    // MARK: - Body
    
    var body: some View {
        makeUI()
    }
    
    // MARK: - UI
    
    private func makeUI() -> some View {
        GeometryReader { geo in
            makeInstructionView(with: geo)
                .task(id: selectedImage, {
                    do {
                        selectedImageData = try await selectedImage?.loadTransferable(type: Data.self)
                        if let selectedImageData, let image = UIImage(data: selectedImageData)?.resized(toWidth: 300), let imageData = image.pngData() {
                            settingsViewModel.saveTransparentBG(imageData)
                        }
                        if selectedImageData == nil {
                            selectedImageData = settingsViewModel.getTransparentBG()
                        }
                        if selectedImageData != nil {
                            isLoadingImage = true
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
    private func makeInstructionView(with geo: GeometryProxy) -> some View {
        VStack {
            makeInstructionView(with: "Transparent Widgets", and: "1.  Long-press Home Screen to jiggle. 2. Scroll furthest right to empty page. 3. Take screenshot (volume-up + sleep button). 4. Choose image below with screenshot. 5. Long-press widget on Home Screen and select “Edit”. 6. Set Background to “Transparent”.", minSide: minSide)
                .frame(height: UIDevice.current.userInterfaceIdiom == .phone ? geo.size.height * 0.45 : geo.size.height * 0.27)
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
            .padding(EdgeInsets(top: 24, leading: 0, bottom: 0, trailing: 0))
         //   makeImageView()
        }
        .padding(EdgeInsets(top: 26, leading: DesignConstants.defaultEdgeDistance, bottom: 0, trailing: DesignConstants.defaultEdgeDistance))
    }
    
    private func makeImageView() -> some View {
        GeometryReader { geo in
            VStack {
                if !isLoadingImage, let previewImage {
                    Image(uiImage: previewImage)
                        .resizable()
                        .scaledToFit()
                        .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                }
                else {
                    if isLoadingImage {
                        ProgressView()
                            .onAppear {
                            if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                                generatePreview(of: uiImage, with: geo.size)
                            }
                        }
                    } else {
                        EmptyView()
                    }
                }
            }
            .rectangleBackground(with: Color(red: 0, green: 0.27, blue: 1), backgroundColor: Color(red: 0, green: 0.27, blue: 1).opacity(0.2), cornerRadius: 12)
            .padding(EdgeInsets(top: 24, leading: 0, bottom: 15, trailing: 0))
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
            Text("Transparent Background")
                .font(
                    Font.custom("DM Sans", size: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 28)
                        .weight(.medium)
                )
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
        }
    }
    
    private func generatePreview(of image: UIImage, with size: CGSize) {
        isLoadingImage = true
        Task.detached {
            let previewImage = await image.byPreparingThumbnail(ofSize: size)
            await MainActor.run {
                withAnimation {
                    self.previewImage = previewImage
                    isLoadingImage = false
                }
            }
        }
    }
    
}

// MARK: - Preview

struct TransperentBGView_Previews: PreviewProvider {
    static var previews: some View {
        TransperentBGView(isShown: .constant(true))
            .environmentObject(SmartPetSettingsViewModel(isForWidget: false))
    }
}
