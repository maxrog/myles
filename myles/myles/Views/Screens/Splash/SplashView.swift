//
//  SplashView.swift
//  myles
//
//  Created by Max Rogers on 12/12/23.
//

import SwiftUI

// TODO better way to load the image asset?
// TODO animate this image to "beat" for a loading page

/// Splash view that is displayed when data is loading
struct SplashView: View {
    
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
    SplashView()
}
