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

    /// A scaled progress color
    static func progressColor(for progress: CGFloat) -> Color {
        switch progress {
        case 0..<0.25:
            return .cosmicLatte
        case 0.25..<0.5:
            return .mylesMedium
        case 0.5..<0.75:
            return .mylesLight
        case 0.75...0.99:
            return .mylesDark
        case 1.0...100.0:
            return .mylesGold
        default:
            return .mylesDark
        }
    }
}

/*
 See https://medium.com/geekculture/using-appstorage-with-swiftui-colors-and-some-nskeyedarchiver-magic-a38038383c5e
 */
extension Color: RawRepresentable {

    /// Conversion for persistence in AppStorage/UserDefaults
    public init?(rawValue: String) {
        guard let data = Data(base64Encoded: rawValue) else {
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
