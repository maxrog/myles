//
//  MylesMarqueeText.swift
//  myles
//
//  Created by Max Rogers on 12/22/23.
//

import SwiftUI

// TODO support no animation if text width is smaller than geo width

/// A marquee text view that animates horizontally and loops indefinitely
struct MylesMarqueeText: View {
    
    @State var text: String
    let font: UIFont
    
    @State private var totalWidth: CGFloat = .zero
    @State private var offset: CGFloat = .zero
    
    var animationSpeed: Double = 0.07
    var delayTime: Double = 1.5
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(text)
                .font(Font(font))
                .offset(x: offset)
                .padding(.horizontal, 15)
        }
        .overlay {
            HStack {
                let color: Color = Color(.systemGray6)
                let colors = [color, color.opacity(0.7), color.opacity(0.5), color.opacity(0.3)]
                LinearGradient(colors: colors,
                               startPoint: .leading,
                               endPoint: .trailing)
                .frame(width: 20)
                .frame(width: 20)
                Spacer()
                LinearGradient(colors: colors.reversed(),
                               startPoint: .leading,
                               endPoint: .trailing)
                .frame(width: 20)
                .frame(width: 20)
            }
        }
        .onAppear {
            let baseText = text
            
            // Spacing for behind base text
            (1...20).forEach { _ in
                text.append(" ")
            }
            // End animation at end of spacing
            totalWidth = text.width(for: font)
            // Duplicate text behind spacing
            text.append(baseText)
            
            animateText()
        }
        .onReceive(Timer.publish(every: animationSpeed * totalWidth, on: .main, in: .default).autoconnect()) { _ in
            offset = 0
            animateText()
        }
    }
    
    private func animateText() {
        let duration: Double = (animationSpeed * totalWidth)
        DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
            withAnimation(.linear(duration: duration)) {
                offset = -totalWidth
            }
        }
    }

}

#Preview {
    MylesMarqueeText(text: "Mi 1 • 9:30 Mi 2 • 9:30 Mi 3 • 9:30 Mi 4 • 9:30 Mi 5 • 9:30 Mi 6 • 9:30 Mi 7 • 9:30", font: UIFont(name: "norwester", size: 13) ?? UIFont.systemFont(ofSize: 13))
}

