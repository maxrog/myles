//
//  EmptyActivityView.swift
//  myles
//
//  Created by Max Rogers on 12/19/23.
//

import SwiftUI

/*
 TODO
 • Whole screen is kinda junk
 • Frowney Face Emoji
 • RocketSim record gif of how user should enable health and put it above or below button
 • TODO we're displaying this sometimes even if user has health allowed and we're simply still loading - look into it.
 */

struct EmptyActivityView: View {
    
    @State private var animationAmount: CGFloat = 1

    var body: some View {
        VStack(spacing: 8) {
            Text("Hmmm, it appears I can't find any data.")
                .font(.custom("norwester", size: 28))
                .multilineTextAlignment(.center)
            Spacer()
                .frame(height: 12)
            Text("Please make sure you have recorded a workout")
                .font(.custom("norwester", size: 16))
                .multilineTextAlignment(.center)
            Spacer()
                .frame(height: 12)
            Text("Health Permission")
                .font(.custom("norwester", size: 22))
            Text("Please make sure you have granted access to read Health data in your Health settings:\n>Settings \n> Health \n> Data Access & Devices \n> myles")
                .font(.custom("norwester", size: 16))
            Spacer()
                .frame(height: 12)
            Button(action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }, label: {
                Text("Settings")
                    .font(.custom("norwester", size: 16))
            }).buttonStyle(MylesButtonStyle(background: Color(.systemGray2), foreground: .white))
        }
    }
}

#Preview {
    EmptyActivityView()
}
