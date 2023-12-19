//
//  MylesIconLabel.swift
//  myles
//
//  Created by Max Rogers on 12/19/23.
//

import SwiftUI

/// LabelStyle that allows customization of spacing between icon and title
struct MylesIconLabel: LabelStyle {
    
    var spacing: Double = 2.0
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: spacing) {
            configuration.icon
            configuration.title
        }
    }
}
