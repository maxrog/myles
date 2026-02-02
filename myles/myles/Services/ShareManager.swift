//
//  ShareManager.swift
//  myles
//
//  Created by Jordan Coe on 2/2/26.
//

import Foundation
import SwiftUI
import UIKit
import Observation

/// Manager for generating and sharing activity images
@Observable
class ShareManager {
    
    init() { }
    
    /// Generates a shareable image containing activity stats
    /// - Parameters:
    ///   - steps: The step count to display
    ///   - distance: The total distance in miles to display
    ///   - date: The date for the activity
    /// - Returns: A UIImage containing the formatted stats, or nil if generation fails
    @MainActor
    func generateActivityImage(steps: Double, distance: Double, date: Date = Date()) async -> UIImage? {
        MylesLogger.log(.action, "Attempting to generate activity image with steps: \(Int(steps)), distance: \(distance.prettyString) mi", sender: String(describing: self))
        
        // Create the SwiftUI view that will be rendered as an image
        let activityView = ActivityShareView(steps: Int(steps), distance: distance, date: date)
        
        // Render the SwiftUI view to UIImage
        let renderer = ImageRenderer(content: activityView)
        
        // Set scale for high quality image (2x for retina, 3x for super retina)
        renderer.scale = UIScreen.main.scale
        
        guard let image = renderer.uiImage else {
            MylesLogger.log(.error, "Failed to generate activity image - renderer returned nil", sender: String(describing: self))
            return nil
        }
        
        MylesLogger.log(.success, "Successfully generated activity image with size: \(image.size)", sender: String(describing: self))
        return image
    }
}

// MARK: - Activity Share View

/// A SwiftUI view designed to be rendered as a shareable image
private struct ActivityShareView: View {
    let steps: Int
    let distance: Double
    let date: Date
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.mylesLight, Color.mylesDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("myles")
                        .font(.custom("norwester", size: 36))
                        .foregroundStyle(.white)
                    
                    Text(date.longCalendarDateFormat)
                        .font(.custom("norwester", size: 16))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding(.top, 32)
                
                Spacer()
                
                // Main stats
                VStack(spacing: 32) {
                    // Steps
                    VStack(spacing: 8) {
                        Image(systemName: "figure.walk")
                            .font(.system(size: 48))
                            .foregroundStyle(.white)
                        
                        Text("\(steps.formatted())")
                            .font(.custom("norwester", size: 56))
                            .foregroundStyle(.white)
                        
                        Text("STEPS")
                            .font(.custom("norwester", size: 20))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    
                    // Distance
                    if distance > 0 {
                        VStack(spacing: 8) {
                            Image(systemName: "figure.run")
                                .font(.system(size: 48))
                                .foregroundStyle(.white)
                            
                            Text("\(distance.prettyString)")
                                .font(.custom("norwester", size: 56))
                                .foregroundStyle(.white)
                            
                            Text("MILES")
                                .font(.custom("norwester", size: 20))
                                .foregroundStyle(.white.opacity(0.9))
                        }
                    }
                }
                
                Spacer()
                
                // Footer
                Text("Keep Moving Forward")
                    .font(.custom("norwester", size: 18))
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.bottom, 32)
            }
            .padding(24)
        }
        .frame(width: 400, height: 600)
    }
}

#Preview {
    ActivityShareView(steps: 12543, distance: 8.44, date: Date())
}
