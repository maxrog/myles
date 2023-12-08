//
//  FoundationExtensions.swift
//  myles
//
//  Created by Max Rogers on 12/8/23.
//

import SwiftUI

// MARK: UserDefaults

extension UserDefaults {
    
    /// Store SwiftUI Color
    func setColor(_ color: Color, forKey key: String) {
        let cgColor = color.cgColor_
        let array = cgColor.components ?? []
        set(array, forKey: key)
    }

    /// Fetch SwiftUIColor
    func color(forKey key: String) -> Color {
        guard let array = object(forKey: key) as? [CGFloat] else { return .accentColor }
        let color = CGColor(colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!, components: array)!
        return Color(color)
    }
    
}
