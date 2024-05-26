//
//  MetricsProgressBarView.swift
//  myles
//
//  Created by Max Rogers on 5/2/24.
//

import SwiftUI

/// A custom progress bar style
struct BarProgressStyle: ProgressViewStyle {
    
    var strokeColor = Color.blue
    var strokeHeight = 24.0
    
    func makeBody(configuration: Configuration) -> some View {
        let progress = configuration.fractionCompleted ?? 0
        
        GeometryReader { geo in
            VStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10.0)
                    .fill(Color(uiColor: .systemGray5))
                    .frame(width:geo.size.width, height: strokeHeight)
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10.0)
                            .fill(strokeColor)
                            .frame(width: geo.size.width * progress)
                            .overlay {
                                if let currentValueLabel = configuration.currentValueLabel {
                                    currentValueLabel
                                        .foregroundStyle(.primary)
                                }
                            }
                    }
            }
        }
    }
}

/// A progress bar view to display current/total values and description text
struct MetricsProgressBarView: View {
    
    var currentValue: Int
    var totalValue: Int
    var descriptionText: String
    var strokeColor: Color?
    var strokeHeight = 24.0
    
    var body: some View {
        
        let progress = Double(min(currentValue, totalValue)) / Double(totalValue)
        
        VStack {
            Spacer()
            Text(descriptionText)
                .font(.custom("norwester", size: 12))
                .foregroundStyle(Color(.systemGray))
                .padding(.bottom, 4)
            HStack {
                Spacer()
                ProgressView(value: Double(min(currentValue, totalValue)), total: Double(totalValue)) { }
            currentValueLabel: {
                Text("\(currentValue)")
                    .font(.custom("norwester", size: 12))
            }
            .progressViewStyle(BarProgressStyle(strokeColor: strokeColor ?? Color(uiColor: UIColor.progressColor(for: progress)),
                                                strokeHeight: strokeHeight))
                Spacer()
            }
            .frame(height: strokeHeight)
            Spacer()
        }
    }
}
