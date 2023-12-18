//
//  MylesRecapViews.swift
//  myles
//
//  Created by Max Rogers on 12/18/23.
//

import SwiftUI

/// An accessory view for showing group of run recap metrics
struct MylesRecapView: View {
    
    /// The run to display recap metrics
    let run: MylesRun
    
    var body: some View {
        VStack() {
            MylesRecapMileageView(run: run)
            if run.hasLocationData {
                MylesMapView(viewModel: MapViewModel(run: run))
                    .frame(height: 200)
                    .clipShape(.rect(cornerSize: CGSize(width: 8, height: 8)))
            } else {
                Button("Load Map") {
                    // TODO if can fetch map, do it - otherwise display indoor icon or something
                }.buttonStyle(.borderedProminent)
            }
            MylesRecapBarView(run: run)
        }.frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview {
    MylesRecapView(run: MylesRun.testRun)
}

// MARK: AccessoryViews

struct MylesRecapHeaderView: View {
    
    var run: MylesRun
    
    var body: some View {
        HStack {
            Text(run.startTime.shortDayOfWeekDateFormat + "." + run.startTime.shortCalendarDateFormat)
                .font(.custom("norwester", size: 18))
            Text("|")
                .font(.custom("norwester", size: 16))
            Text("\(run.duration.prettyTimeString)")
                .font(.custom("norwester", size: 18))
        }
    }
}

struct MylesRecapMileageView: View {
    
    var run: MylesRun
    
    var body: some View {
        Text("\(run.distance.prettyString) mi")
            .font(.custom("norwester", size: 28))
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color(.systemGray4))
            )
    }
}

struct MylesRecapBarView : View {
    
    var run: MylesRun
    
    var body: some View {
        HStack {
            Label("\(run.averagePace)/mi", systemImage: "stopwatch")
                .font(.custom("norwester", size: 13))
                .labelStyle(CustomLabel(spacing: 2))
            if let heartRate = run.averageHeartRateBPM, heartRate > 0 {
                Label("\(heartRate)", systemImage: "heart")
                    .font(.custom("norwester", size: 13))
                    .labelStyle(CustomLabel(spacing: 2))
            }
            if let elevation = run.elevationChange.gain, elevation > 0 {
                Label("\(elevation) ft", systemImage: "arrow.up.forward")
                    .font(.custom("norwester", size: 13))
                    .labelStyle(CustomLabel(spacing: 2))
            }
            if let temp = run.weather.temperature {
                Label("\(temp)°F", systemImage: temp > 30 ? "thermometer.sun" : "thermometer.snowflake")
                    .font(.custom("norwester", size: 13))
                    .labelStyle(CustomLabel(spacing: 2))
            }
        }
    }
}
