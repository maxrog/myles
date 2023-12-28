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
 */

@main
struct mylesApp: App {
    
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var theme: ThemeManager = ThemeManager()
    @StateObject var health: HealthManager = HealthManager()
    @StateObject var shoes: ShoeManager = ShoeManager()
   
    var body: some Scene {
        WindowGroup {
            switch theme.preferredStyle {
            case .dark:
                TabNavigationView()
                    .environmentObject(theme)
                    .environmentObject(health)
                    .environmentObject(shoes)
                    .preferredColorScheme(.dark)
            case .light:
                TabNavigationView()
                    .environmentObject(theme)
                    .environmentObject(health)
                    .environmentObject(shoes)
                    .preferredColorScheme(.light)
            case .system:
                TabNavigationView()
                    .environmentObject(theme)
                    .environmentObject(health)
                    .environmentObject(shoes)
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
