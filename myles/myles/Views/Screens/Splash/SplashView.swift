//
//  SplashView.swift
//  myles
//
//  Created by Max Rogers on 12/12/23.
//

import SwiftUI

/// Splash view that is displayed while data is loading
struct SplashView: View {

    @Environment(HealthManager.self) var health

    @State private var animationAmount: CGFloat = 1
    @Binding var splashComplete: Bool
    @State private var attemptedWorkoutProcess = false

    var body: some View {
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
                                splashComplete = false
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
        .task {
            await configureHealthStore()
        }
    }

    @MainActor
    private func configureHealthStore() async {
        guard await health.requestPermission() else { return }
        await health.processWorkouts()
        self.attemptedWorkoutProcess = true
        self.splashComplete = true
    }
}

#Preview {
    SplashView(splashComplete: Binding.constant(false))
}
