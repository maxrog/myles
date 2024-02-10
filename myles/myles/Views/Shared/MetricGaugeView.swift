//
//  MetricGaugeView.swift
//  myles
//
//  Created by Max Rogers on 2/10/24.
//

import SwiftUI


/// A custom metric gauge view for showing progress
struct MetricGaugeView: View {
    
    let progress: Double
    let total: String
    let metric: String
    
    var progressColor: UIColor {
        switch progress {
        case 0..<0.25:
            return UIColor(named: "CosmicLatte") ?? .white
        case 0.25..<0.5:
            return UIColor(named: "mylesMedium") ?? .orange
        case 0.5..<0.75:
            return UIColor(named: "mylesLight") ?? .orange
        case 0.75...1:
            return UIColor(named: "mylesDark") ?? .red
        default:
            return UIColor(named: "CosmicLatte") ?? .white
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ZStack {
                    Circle()
                        .stroke(
                            Color(.systemGray2),
                            lineWidth: 8
                        )
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            Color(uiColor: progressColor),
                            style: StrokeStyle(
                                lineWidth: 8,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut, value: progress)
                }
                VStack {
                    Text(total)
                        .font(.custom("norwester", size: 28))
                        .lineLimit(2)
                    Text(metric)
                        .font(.custom("norwester", size: 12))
                }.frame(width: geo.size.width * 0.9)
            }
        }
    }
    
}
