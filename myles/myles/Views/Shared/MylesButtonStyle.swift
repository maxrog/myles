//
//  MylesButtonStyle.swift
//  myles
//
//  Created by Max Rogers on 12/19/23.
//

import SwiftUI

/// Customizable button style
struct MylesButtonStyle: ButtonStyle {

    var background: Color = .clear
    var foreground: Color = .primary
    var border: Color?
    var cornerRadius: CGFloat = 8.0

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 2) {
            if let border = border {
                configuration.label
                    .padding()
                    .foregroundStyle(foreground)
                    .background(background)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .inset(by: 1) // inset value should be same as lineWidth in .stroke
                            .stroke(border, lineWidth: 1)
                    )
                    .scaleEffect(configuration.isPressed ? 1.125 : 1)
                    .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            } else {
                configuration.label
                    .padding()
                    .foregroundStyle(foreground)
                    .background(background)
                    .clipShape(.rect(cornerRadius: cornerRadius))
                    .scaleEffect(configuration.isPressed ? 1.125 : 1)
                    .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            }
        }
    }
}
