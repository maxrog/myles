//
//  LastLongRunView.swift
//  myles
//
//  Created by Max Rogers on 5/26/24.
//

import SwiftUI

struct LastLongRunView: View {
    
    @Environment(HealthManager.self) var health
    
    @State private var longRun: MylesRun?
    @AppStorage("com.marfodub.myles.LongRunRange") var longRunRangeWeekCount: Int = 8
    @State private var lastLongRunHeader = ""
    private func updateLongRun() {
        self.lastLongRun = health.runs.first(where: { $0 == health.longestRecentLongRun(longRunRangeWeekCount) })
        lastLongRunHeader = "Last \(longRunRangeWeekCount) \(longRunRangeWeekCount > 1 ? "Weeks" : "Week")"
    }
    @State private var lastLongRun: MylesRun?
    
    var body: some View {
        Section {
            VStack {
                HStack(spacing: 12) {
                    Image(systemName: "flame")
                        .frame(width: 35, height: 35)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundStyle(.mylesDark)
                        )
                    Stepper(onIncrement: {
                        longRunRangeWeekCount += 1
                        updateLongRun()
                    }, onDecrement: {
                        guard longRunRangeWeekCount > 1 else { return }
                        longRunRangeWeekCount -= 1
                        updateLongRun()
                    }, label: {
                        Text(NSLocalizedString("Long Run", comment: ""))
                            .font(.custom("norwester", size: 16))
                    })
                }
                .padding(EdgeInsets(top: 3, leading: 0, bottom: 3, trailing: 0))
                
                if let longRun = lastLongRun {
                    RecapHeaderView(run: longRun)
                    RecapView(viewModel: RecapViewModel(health: health,
                                                        run: longRun,
                                                        expanded: false,
                                                        showMap: longRun.hasLocationData))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowInsets(EdgeInsets())
                }
            }
        } header: {
            Text(lastLongRunHeader)
                .font(.custom("norwester", size: 16))
        }
        .onAppear {
            updateLongRun()
        }
    }
}
