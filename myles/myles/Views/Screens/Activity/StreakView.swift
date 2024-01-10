//
//  StreakView.swift
//  myles
//
//  Created by Max Rogers on 12/19/23.
//

import SwiftUI

struct StreakView: View {
    
    @EnvironmentObject var theme: ThemeManager

    var streakCount: Int
    
    var body: some View {
        Label("\(streakCount)", systemImage: "repeat.circle.fill")
            .labelStyle(MylesIconLabel())
            .font(.custom("norwester", size: 20))
            .foregroundStyle(theme.accentColor)
    }
}

#Preview {
    StreakView(streakCount: 100)
}
