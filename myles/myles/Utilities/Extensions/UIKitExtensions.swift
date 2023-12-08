//
//  UIKitExtensions.swift
//  myles
//
//  Created by Max Rogers on 12/8/23.
//

import Foundation

import UIKit

// MARK: UIApplication

extension UIApplication {
    
    /// The main scene used throughout the app
    public static var mainScene: UIScene? {
        Self.shared.connectedScenes.first
    }
    
}
