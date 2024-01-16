//
//  mylesApp.swift
//  myles
//
//  Created by Max Rogers on 12/8/23.
//

import SwiftUI

/*
 TODO
 • Observation Swift 5.9 Refactor
 • SF Symbol Animation
 • Refactor .font(.custom("norwester", size: 28)) to something more reliable (Fonts Struct or something in theming) Allow user to change font?
 • Refactor references to Asset images to something more reliable
 • Xcode Cloud
 • #if DEBUG if needed
 */

@main
struct mylesApp: App {
    
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var theme: ThemeManager = ThemeManager()
    @State var health: HealthManager = HealthManager()
    @State var shoes: ShoeManager = ShoeManager()
   
    var body: some Scene {
        WindowGroup {
            switch theme.preferredStyle {
            case .dark:
                TabNavigationView()
                    .environmentObject(theme)
                    .environment(health)
                    .environment(shoes)
                    .preferredColorScheme(.dark)
            case .light:
                TabNavigationView()
                    .environmentObject(theme)
                    .environment(health)
                    .environment(shoes)
                    .preferredColorScheme(.light)
            case .system:
                TabNavigationView()
                    .environmentObject(theme)
                    .environment(health)
                    .environment(shoes)
                    .preferredColorScheme(.none)
            }
        }.onChange(of: scenePhase, { oldValue, newValue in
            var oldPhase = ""
            var newPhase = ""
            switch oldValue {
            case .active: oldPhase = "active"
            case .background: oldPhase = "backgrounded"
            case .inactive: oldPhase = "inactive"
            default: break
            }
            switch newValue {
            case .active: newPhase = "active"
            case .background: newPhase = "backgrounded"
            case .inactive: newPhase = "inactive"
            default: break
            }
            Logger.log(.action, "Scene changed from \(oldPhase) to \(newPhase)", sender: String(describing: self))
        })
    }
}
