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
 • TODO we're displaying this sometimes even if user has health allowed and we're simply still loading - look into it. For now we have placeholder splash thing - we want the empty flow similar to what's commented out
 */

struct EmptyActivityView: View {
    
    @State private var animationAmount: CGFloat = 1

    var body: some View {
//        Text("Hmmm, it appears I can't find any workout data.")
//            .font(.title)
//        Text("Please make sure you have recorded a running workout")
//        Text("Please make sure you have granted access to read Health data in Settings -> Health -> Data Access & Devices -> Miles")
//        Button(action: {
//            if let url = URL(string: UIApplication.openSettingsURLString) {
//                UIApplication.shared.open(url, options: [:], completionHandler: nil)
//            }
//        }, label: {
//            Text("Settings")
//        }).buttonStyle(MylesButtonStyle())
        
        GeometryReader { geo in
            if let image = UIImage(named: "mylesHeart") {
                VStack(alignment: .center, spacing: 0) {
                    Spacer()
                    HStack(alignment: .center, spacing: 0) {
                        Spacer()
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geo.size.width * 0.6, height: geo.size.width * 0.6)
                            .scaleEffect(animationAmount)
                            .animation(
                                .spring(response: 0.2, dampingFraction: 0.3, blendDuration: 0.8)
                                    .delay(0)
                                    .repeatForever(autoreverses: true),
                                value: animationAmount)
                            .onAppear {
                                animationAmount = 0.8
                            }
                        Spacer()
                    }
                    .offset(y: -64)
                    Spacer()
                }
                .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    EmptyActivityView()
}
