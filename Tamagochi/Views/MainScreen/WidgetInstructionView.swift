//
//  WidgetInstructionView.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI

// APP REFACTORING

private func tamagochiVVV_Vlad(_ korean: Bool, girls: Bool) -> Int {
    let firstGirl = "Lee Chae Yeon"
    let secondGirl = "Lee Chae Ryeong"
    return firstGirl.count + secondGirl.count
}

//

struct WidgetInstructionView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var minSide = 0.0
    @State private var selected = WidgetInstruction.home
    
    @Binding var isShown: Bool
    
    // MARK: - Body
    
    var body: some View {
        makeUI()
    }
    
    // MARK: - UI
    
    private func makeUI() -> some View {
        GeometryReader { geo in
            VStack {
                SegmentControl_TamagochiVVV(data:
                                [SegmentControl_TamagochiVVV.Data_TamagochiVVV(image: Image("house"), text: "Home Screen", type: .home),
                                 SegmentControl_TamagochiVVV.Data_TamagochiVVV(image: Image("lock"), text: "Lock Screen", type: .lock)],
                               selectedValue: $selected)
                .frame(height: 56)
                if selected == .home {
                    makeHomeInsturction(with: geo)
                } else {
                    makeLockInstruction(with: geo)
                }
            }
            .padding(EdgeInsets(top: 26, leading: DesignConstants.defaultEdgeDistance, bottom: 0, trailing: DesignConstants.defaultEdgeDistance))
            .font(Font.custom("DM Sans", size: minSide / 26))
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
    private func makeHomeInsturction(with geo: GeometryProxy) -> some View {
        makeInstructionView(with: "To Add", and: "1.  Long-press Home Screen to jiggle. 2. Tap + in top left corner 3. Scroll down and select “Widgets”", minSide: minSide)
            .frame(height: UIDevice.current.userInterfaceIdiom == .phone ? geo.size.height * 0.25 : geo.size.height * 0.2)
            .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
        makeInstructionView(with: "To Customize", and: "1.  Long-press Home Screen to jiggle. 2. Tap on Widgets", minSide: minSide)
            .frame(height: UIDevice.current.userInterfaceIdiom == .phone ? geo.size.height * 0.2 : geo.size.height * 0.15)
            .padding(EdgeInsets(top: 24, leading: 0, bottom: 0, trailing: 0))
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
    }
    
    @ViewBuilder
    private func makeLockInstruction(with geo: GeometryProxy) -> some View {
        makeInstructionView(with: "To Add", and: "1.  Long-press Lock Screen and select “Customize”. 2. Tap the square underneath the time 3. Scroll down and select “Widgets”", minSide: minSide)
            .frame(height: UIDevice.current.userInterfaceIdiom == .phone ? geo.size.height * 0.3 : geo.size.height * 0.2)
            .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
            .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
        makeInstructionView(with: "To Customize", and: "1.  Long-press Lock Screen and select “Customize”. 2. Tap on Widgets", minSide: minSide)
            .frame(height: UIDevice.current.userInterfaceIdiom == .phone ? geo.size.height * 0.25 : geo.size.height * 0.15)
            .padding(EdgeInsets(top: 24, leading: 0, bottom: 0, trailing: 0))
            .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
    }
    
    @ToolbarContentBuilder
    private func makeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: {
                dismiss()
            }, label: {
                Image(systemName: "chevron.left")
                    .resizable()
                    .foregroundColor(.white)
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            })
            .padding(.leading, UIDevice.current.userInterfaceIdiom == .pad ? 45 : 0)
        }
        ToolbarItem(placement: .principal) {
            Text("Widget Instruction")
                .font(
                    Font.custom("DM Sans", size: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 28)
                        .weight(.medium)
                )
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
        }
    }
    
}

// MARK: - Preview

struct WidgetInstructionView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetInstructionView(isShown: .constant(true))
    }
}
