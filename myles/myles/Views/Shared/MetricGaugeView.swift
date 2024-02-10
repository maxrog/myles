//
//  MetricGaugeView.swift
//  myles
//
//  Created by Max Rogers on 2/10/24.
//

import SwiftUI


struct MetricGaugeView: View {
    
    let progress: Double
    let total: String
    let metric: String
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ZStack {
                    Circle()
                        .stroke(
                            Color.pink.opacity(0.5),
                            lineWidth: 8
                        )
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            Color.pink,
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
