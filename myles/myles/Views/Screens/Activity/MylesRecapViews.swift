//
//  MylesRecapViews.swift
//  myles
//
//  Created by Max Rogers on 12/18/23.
//

import SwiftUI

/// An accessory view for showing group of run recap metrics
struct MylesRecapView: View {
    
    @StateObject private var health = HealthStoreManager.shared

    /// The run to display recap metrics
    @StateObject var run: MylesRun
    
    /// Whether the map was attempted to load and failed, indicating indoor workout
    @State var failedToLoadMap = false
    
    var body: some View {
        VStack() {
            MylesRecapMileageView(run: run)
            if run.hasLocationData {
                MylesMapView(viewModel: MapViewModel(run: run))
                    .frame(height: 200)
                    .clipShape(.rect(cornerRadius: 8))
            } else if run.emptyLocationDataOnInitialLoad || failedToLoadMap {
                Image(systemName: "figure.elliptical")
                    .font(.system(size: 60))
                    .padding(EdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40))
                    .background(Color(.systemGray4))
                    .cornerRadius(8)
            } else {
                Button() {
                    Task {
                        let mapAvailable = await health.loadMapData(for: run)
                        withAnimation {
                            failedToLoadMap = !mapAvailable
                        }
                    }
                } label: {
                    Label("Load Map", systemImage: "point.topleft.down.to.point.bottomright.filled.curvepath")
                        .font(.custom("norwester", size: 18))
                        .labelStyle(MylesIconLabel())
                }
                .buttonStyle(MylesButtonStyle(background: .blue))
            }
            MylesRecapBarView(run: run)
        }.frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview {
    MylesRecapView(run: MylesRun.testRun)
}

// MARK: AccessoryViews

/// Recap header view containing run date and duration information
struct MylesRecapHeaderView: View {
    
    @StateObject var run: MylesRun
    
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

/// Recap view containing run mileage
struct MylesRecapMileageView: View {
    
    @StateObject var run: MylesRun
    
    var body: some View {
        Text("\(run.distance.prettyString) mi")
            .font(.custom("norwester", size: 28))
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color(.systemGray4))
            )
    }
}

/// Recap view containing run accessory data including pace, heart rate, elevation, and temp
struct MylesRecapBarView : View {
    
    @StateObject var run: MylesRun
    
    var body: some View {
        HStack {
            Label("\(run.averagePace)/mi", systemImage: "stopwatch")
                .font(.custom("norwester", size: 13))
                .labelStyle(MylesIconLabel())
            if let heartRate = run.averageHeartRateBPM, heartRate > 0 {
                Label("\(heartRate)", systemImage: "heart")
                    .font(.custom("norwester", size: 13))
                    .labelStyle(MylesIconLabel())
            }
            if let elevation = run.elevationChange.gain, elevation > 0 {
                Label("\(elevation) ft", systemImage: "arrow.up.forward")
                    .font(.custom("norwester", size: 13))
                    .labelStyle(MylesIconLabel())
            }
            if run.hasLocationData, let temp = run.weather.temperature {
                Label("\(temp)°F", systemImage: temp > 30 ? "thermometer.sun" : "thermometer.snowflake")
                    .font(.custom("norwester", size: 13))
                    .labelStyle(MylesIconLabel())
            }
        }
    }
}
