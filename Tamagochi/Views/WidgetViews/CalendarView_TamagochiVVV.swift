//
//  CalendarView_TamagochiVVV.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI

struct CalendarView_TamagochiVVV: WidgetView_TamagochiVVV {
    
    // MARK: - Properties
    
    @EnvironmentObject var widgetsViewModel: WidgetsViewModel
    
    @State var minSide: Double = 1.0
    
    let type: WidgetType_TamagochiVVV = .calendar
    let previewAnimals: [UIImage]
    let bgImage: UIImage
    
    // MARK: - Body

    var body: some View {
        makeUI()
    }
    
    // MARK: - UI
    
    private func makeUI() -> some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                HStack {
                    Text(widgetsViewModel.widgetData.date.getMonthTitle().uppercased())
                        .font(widgetsViewModel.widgetData.textStyle.getFontWithSize(minSide / 12))
                        .padding([.leading, .top])
                    Spacer()
                }
                HStack(spacing: 0) {
                    ForEach(1..<8, id: \.self) { dayIndex in
                        Text(Date.getVeryShortDayName(for: dayIndex))
                            .minimumScaleFactor(0.2)
                            .font(widgetsViewModel.widgetData.textStyle.getFontWithSize(minSide / 14))
                            .frame(width: minSide / 8.5, height: minSide / 8.5)
                    }
                }
                makeDaysView(with: geo)
            }
            .minimumScaleFactor(1)
            .onAppear {
                minSide = min(geo.size.width, geo.size.height)
            }
            .onChange(of: geo.size) { newValue in
                minSide = min(newValue.width, newValue.height)
            }
            .padding(.bottom)
            .frame(maxWidth: geo.size.width, maxHeight: geo.size.height)
            .overlay {
                getOverlay(with: geo)
            }
            .widgetModifier(with: widgetsViewModel.isForWidget ? 0 : minSide, and: getBackground(with: geo), foregroundColor: widgetsViewModel.widgetData.textColor.color)
        }
    }
    
    private func makeDaysView(with geo: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            let minSide = min(geo.size.width, geo.size.height)
            ForEach(Date.getWeeksInMonth(from: widgetsViewModel.widgetData.date), id: \.self) { week in
                HStack(spacing: 0) {
                    ForEach(week, id: \.self) { day in
                        Text(day <= 0 ? "" : String(day))
                            .minimumScaleFactor(0.2)
                            .frame(width: minSide / 8.5, height: minSide / 8.5)
                            .font(widgetsViewModel.widgetData.textStyle.getFontWithSize(minSide / 18))
                            .foregroundColor(widgetsViewModel.widgetData.date.isEqualTo(dayIndex: day) ? widgetsViewModel.widgetData.textColor.color.oppositeColor : widgetsViewModel.widgetData.textColor.color)
                            .background(widgetsViewModel.widgetData.date.isEqualTo(dayIndex: day) ? widgetsViewModel.widgetData.textColor.color : Color.clear)
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func getOverlay(with geo: GeometryProxy) -> some View {
        if !widgetsViewModel.shouldApplyOffset() {
            getOverlay(with: geo, and: .zero)
        } else if geo.size.width == geo.size.height {
            VStack{
                HStack {
                    Spacer()
                    getOverlay(with: geo, and: .zero)
                }
                Spacer()
            }
            .padding(.zero)
        } else {
            HStack {
                getOverlay(with: geo, and: .zero)
                Spacer()
            }
            .padding([.leading])
        }
    }
    
}

// MARK: - Preview

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView_TamagochiVVV(previewAnimals: [UIImage(named: "cat_1_run_1")!, UIImage(named: "cat_1_run_2")!, UIImage(named: "cat_1_run_3")!, UIImage(named: "cat_1_run_4")!], bgImage: UIImage(named: "cat_1_normal")!)
            .preferredColorScheme(.light)
            .frame(width: 350, height: 350)
            .environmentObject(WidgetsViewModel())
    }
}

