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
    let goal: Int?
    let metric: String
    
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
                            Color(uiColor: UIColor.progressColor(for: progress)),
                            style: StrokeStyle(
                                lineWidth: 8,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut, value: progress)
                }
                VStack(spacing: 0) {
                    Text(total)
                        .font(.custom("norwester", size: 28))
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)
                        .padding(.horizontal, 6)
                    Text(metric)
                        .font(.custom("norwester", size: 12))
                        .minimumScaleFactor(0.75)
                        .padding(.horizontal, 6)
                }.frame(width: geo.size.width * 0.9)
                VStack {
                    HStack {
                        Spacer()
                        if let goal = goal, goal > 0 {
                            Label("\(goal)", systemImage: "star.circle.fill")
                                .font(.custom("norwester", size: 10))
                                .labelStyle(MylesIconLabel())
                        }
                    }
                    Spacer()
                }
            }
        }
    }
    
}
