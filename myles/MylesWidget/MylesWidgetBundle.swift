//
//  MylesWidgetBundle.swift
//  MylesWidget
//
//  Created by Max Rogers on 1/24/24.
//

import WidgetKit
import SwiftUI

/// Declares supported Widgets
@main
struct MylesWidgetBundle: WidgetBundle {
    var body: some Widget {
        MetricWidget()
        CombinedMetricsWidget()
        StepsWidget()
    }
}
