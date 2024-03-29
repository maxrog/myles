//
//  StreakView.swift
//  myles
//
//  Created by Max Rogers on 12/19/23.
//

import SwiftUI

/// A view that displays a user's run streak count
struct StreakView: View {
    
    var streakCount: Int
    
    var body: some View {
        Label("\(streakCount)", systemImage: "repeat.circle.fill")
            .labelStyle(MylesIconLabel())
            .font(.custom("norwester", size: 20))
            .foregroundStyle(Color(uiColor: UIColor(named: "mylesGold") ?? .green))
    }
}

#Preview {
    StreakView(streakCount: 100)
}
