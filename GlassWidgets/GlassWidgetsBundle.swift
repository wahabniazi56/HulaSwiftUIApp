//
//  GlassWidgetsBundle.swift
//  GlassWidgets
//
//  Created by mac on 25/09/2026.
//

import WidgetKit
import SwiftUI

@main
struct GlassWidgetsBundle: WidgetBundle {
    var body: some Widget {
        GlassWidgets()
        GlassWidgetsControl()
        GlassWidgetsLiveActivity()
    }
}
