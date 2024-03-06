//
//  ThemeManager.swift
//  myles
//
//  Created by Max Rogers on 12/8/23.
//

import Foundation
import SwiftUI

/*
TODO test system preference + changing back and forth
 TODO dynamic text (Use System Text Size / slider for text size (if not use system text size)
 TODO app icon switcher
 TODO migrate to @Observable once these computed properties are supported
 */

/// Manager for the user's app/color theme preference
class ThemeManager: ObservableObject {
    
    /// Standard user defaults
    let userDefaults = UserDefaults.standard
    
    /// Default
    static let defaultAccentColor = (UIScreen.main.traitCollection.userInterfaceStyle == .dark) ? Color(uiColor: UIColor(named: "CosmicLatte") ?? .white) : Color(uiColor: UIColor(named: "mylesMedium") ?? .white)
    
    init() {
        setupTheme()
    }
    
    /// Configuration for launch
    private func setupTheme() {
        // First launch with no value
        if userDefaults.value(forKey: ThemeUserDefaults.applySystemKey) == nil {
            useSystemSetting = true
        } else {
            applyDarkMode = useSystemSetting ? systemInDarkMode : userDefaults.bool(forKey: ThemeUserDefaults.applyDarkModeKey)
        }
        self.accentColor = userDefaults.color(forKey: ThemeUserDefaults.accentColorKey) ?? Self.defaultAccentColor
    }
    
    // MARK: Preferences
    
    /// The user's preferred theming style
    @Published private(set) var preferredStyle: PreferredUserInterfaceStyle = .system
    
    /// Whether user has opted to use something other than system settings
    var useSystemSetting: Bool {
        get { userDefaults.bool(forKey: ThemeUserDefaults.applySystemKey) }
        set {
            userDefaults.set(newValue, forKey: ThemeUserDefaults.applySystemKey)
            updateThemeSubject()
        }
    }
    
    /// Whether user has opted for a light or a dark mode
    var applyDarkMode: Bool {
        get { userDefaults.bool(forKey: ThemeUserDefaults.applyDarkModeKey) }
        set {
            userDefaults.set(newValue, forKey: ThemeUserDefaults.applyDarkModeKey)
            updateThemeSubject()
        }
    }
    
    /// Update the current value subject when settings change
    private func updateThemeSubject() {
        if useSystemSetting {
            userDefaults.set(systemInDarkMode, forKey: ThemeUserDefaults.applyDarkModeKey)
            preferredStyle = .system
        } else {
            userDefaults.set(false, forKey: ThemeUserDefaults.applySystemKey)
            preferredStyle = applyDarkMode ? .dark : .light
        }
        MylesLogger.log(.action, "Theme configured with values: Preferred Style = \(preferredStyle.rawValue), System Setting = \(useSystemSetting), Dark Mode = \(applyDarkMode)", sender: String(describing: self))
    }
    
    // MARK: Colors
    
    /// Determines whether system is in dark mode
    private lazy var systemInDarkMode: Bool = {
        UIScreen.main.traitCollection.userInterfaceStyle == .dark
    }()
    
    /// Theme text color (if overriding system settings)
    var textColor: Color {
        switch preferredStyle {
        case .dark:
            return Color.white
        case .light:
            return Color.black
        case .system:
            return Color(.label)
        }
    }
    
    /// Theme background color (if overriding system settings)
    var backgroundColor: Color {
        switch preferredStyle {
        case .dark:
            return Color.black
        case .light:
            return Color.white
        case .system:
            return Color(.systemBackground)
        }
    }
    
    /// Theme accent color
    @Published var accentColor: Color = defaultAccentColor {
        didSet {
            userDefaults.setColor(accentColor, forKey: ThemeUserDefaults.accentColorKey)
        }
    }
    
}

/// User's preferred user interface style
enum PreferredUserInterfaceStyle: String {
    case dark, light, system
}

/// User Default Keys
private struct ThemeUserDefaults {
    static let applySystemKey = "rogers.max.myles.applysystemsettingkey"
    static let applyDarkModeKey = "rogers.max.myles.applydarkmodekey"
    
    static let accentColorKey = "rogers.max.themeaccentcolor"
}

