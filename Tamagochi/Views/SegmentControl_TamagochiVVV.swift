//
//  SegmentControl_TamagochiVVV.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI

struct SegmentControl_TamagochiVVV<T: RawRepresentable>: View where T.RawValue == String {
    
    // MARK: - Properties
    
    struct Data_TamagochiVVV: Identifiable {
        
        var id: String {
            type.rawValue
        }
        
        let image: Image?
        let text: String
        let type: T
        
    }
    
    var data: [Data_TamagochiVVV]
    
    @Binding var selectedValue: T
    
    @Namespace private var selectedValueNamespace
    
    // MARK: - Body
    
    var body: some View {
        makeUI()
    }
    
    // MARK: - UI
    
    private func makeUI() -> some View {
        GeometryReader { geo in
            let minSide = min(geo.size.width, geo.size.height)
            HStack {
                ForEach(data, content: { value in
                    ZStack {
                        if selectedValue.rawValue == value.id {
                            RoundedRectangle(cornerRadius: 12)
                                .inset(by: 0.5)
                                .stroke(Color(red: 0, green: 0.27, blue: 1), lineWidth: 1)
                                .background(Color(red: 0, green: 0.27, blue: 1).opacity(0.2).cornerRadius(12))
                                .matchedGeometryEffect(id: "selectedIndex", in: selectedValueNamespace)
                                .padding(.all, 4)
                        }
                        Button(action: {
                            withAnimation {
                                selectedValue = value.type
                            }
                        }, label: {
                            HStack {
                                Spacer()
                                if let image = value.image {
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: geo.size.height * 0.5)
                                }
                                Text(value.text)
                                Spacer()
                            }
                        })
                    }
                })
            }
            .lineLimit(1)
            .font(Font.custom("DM Sans", size: UIDevice.current.userInterfaceIdiom == .phone ? 14 : 16))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.2)
            .background {
                Color.black
                    .cornerRadius(12)
            }
        }
    }
    
}

// MARK: - Preview

struct SegmentControl_Previews: PreviewProvider {
    static var previews: some View {
        SegmentControl_TamagochiVVV(data: [SegmentControl_TamagochiVVV.Data_TamagochiVVV(image: nil, text: "Home Screen", type: .home), SegmentControl_TamagochiVVV.Data_TamagochiVVV(image: nil, text: "Home Screen", type: .lock)], selectedValue: .constant(WidgetInstruction.home))
            .frame(height: 100)
    }
}
