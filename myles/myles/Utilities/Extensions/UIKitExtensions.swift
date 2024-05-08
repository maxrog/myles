//
//  UIKitExtensions.swift
//  myles
//
//  Created by Max Rogers on 12/8/23.
//

import Foundation

import UIKit

// MARK: - UIColor

extension UIColor {
    
    /// A scaled progress color
    static func progressColor(for progress: CGFloat) -> UIColor {
        switch progress {
        case 0..<0.25:
            return UIColor(named: "CosmicLatte") ?? .white
        case 0.25..<0.5:
            return UIColor(named: "mylesMedium") ?? .orange
        case 0.5..<0.75:
            return UIColor(named: "mylesLight") ?? .orange
        case 0.75...0.99:
            return UIColor(named: "mylesDark") ?? .red
        default:
            return UIColor(named: "mylesGold") ?? .green
        }
    }
    
}
