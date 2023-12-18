//
//  SwiftUIExtensions.swift
//  myles
//
//  Created by Max Rogers on 12/8/23.
//

import SwiftUI

// MARK: Color

extension Color {
    /// Conversion with persistance in mind
    var cgColor_: CGColor { UIColor(self).cgColor }
}

/*
 See https://medium.com/geekculture/using-appstorage-with-swiftui-colors-and-some-nskeyedarchiver-magic-a38038383c5e
 */
extension Color: RawRepresentable {
        
    /// Conversion for persistence in AppStorage/UserDefaults
    public init?(rawValue: String) {
        guard let data = Data(base64Encoded: rawValue) else{
            self = .black
            return
        }
        do {
            let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) ?? .clear
            self = Color(color)
        } catch {
            self = .black
        }
    }

    /// Conversion for persistence in AppStorage/UserDefaults
    public var rawValue: String {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: UIColor(self), requiringSecureCoding: false) as Data
            return data.base64EncodedString()
        } catch {
            return ""
        }
    }
}

// MARK: Label

/// Ability to customize the spacing between icon and title in a Label
struct CustomLabel: LabelStyle {
    
    var spacing: Double = 0.0
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: spacing) {
            configuration.icon
            configuration.title
        }
    }
}
