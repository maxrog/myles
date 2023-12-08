//
//  mylesApp.swift
//  myles
//
//  Created by Max Rogers on 12/8/23.
//

import SwiftUI

/*
 • Swift 5.9 / macros simplified swiftUI property Wrappers? Only @State @Environment @Binding ??? Look into this!
 • SF Symbol Animation
 */

@main
struct mylesApp: App {
    
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var theme: ThemeManager = ThemeManager()
   
    var body: some Scene {
        WindowGroup {
            switch theme.preferredStyle {
            case .dark:
                TabNavigationView()
                    .environmentObject(theme)
                    .preferredColorScheme(.dark)
            case .light:
                TabNavigationView()
                    .environmentObject(theme)
                    .preferredColorScheme(.light)
            case .system:
                TabNavigationView()
                    .environmentObject(theme)
                    .preferredColorScheme(.none)
            }
        }.onChange(of: scenePhase) { newScenePhase in
            switch scenePhase {
            case .active:
                Logger.log(.action, "Scene active", sender: String(describing: self))
            case .background:
                Logger.log(.action, "Scene backgrounded", sender: String(describing: self))
            case .inactive:
                Logger.log(.action, "Scene inactive", sender: String(describing: self))
            default:
                break
            }
        }
    }
}
