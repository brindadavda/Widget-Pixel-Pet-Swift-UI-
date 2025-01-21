//
//  TamagochiWidgetBundle.swift
//  TamagochiWidget
//
//  Created by Systems
//

import WidgetKit
import SwiftUI

@main
struct TamagochiWidgetBundle: WidgetBundle {
    var body: some Widget {
        TamagochiWidget()
        TamagochiWidgetLS()
        TamagochiWidgetLiveActivity()
    }
}
