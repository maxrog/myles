//
//  EmptyActivityView.swift
//  myles
//
//  Created by Max Rogers on 12/19/23.
//

import SwiftUI

/*
 TODO
• RocketSim record gif of how user should enable health and put it above or below button
 */

struct EmptyActivityView: View {
    var body: some View {
        Text("Hmmm, it appears I can't find any workout data.")
            .font(.title)
        Text("Please make sure you have recorded a running workout")
        Text("Please make sure you have granted access to read Health data in Settings -> Health -> Data Access & Devices -> Miles")
        Button(action: {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }, label: {
            Text("Settings")
        }).buttonStyle(MylesButtonStyle())
    }
}

#Preview {
    EmptyActivityView()
}
