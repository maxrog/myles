//
//  ActivityView.swift
//  myles
//
//  Created by Max Rogers on 12/12/23.
//

import SwiftUI
import HealthKit

struct ActivityView: View {
    
    @StateObject private var health = HealthKitManager.shared
    @State var healthPermissionGranted = true
        
    var body: some View {
        VStack {
            if health.runs.count > 0 {
                List(health.runs) {
                    run in
                    VStack {
                        Text("\(run.miles) mi")
                            .font(.largeTitle)
                        Text(run.startTime.shortCalendarDateFormat)
                            .font(.headline)
                        Text(run.startTime.shortDayOfWeekDateFormat)
                        Text("Duration \(run.duration)")
                        Text("BPM \(run.averageHeartRateBPM ?? 0)")
                        Text("Elevation Gain \(run.elevationChange.gain ?? 0) ft")
                        Text("Elevation Loss \(run.elevationChange.loss ?? 0) ft")
                        Text("Temp \(run.weather.temperature ?? 0) F")
                        Text("Humidity \(run.weather.humidity ?? 0) %")
                    }
                }
              } else if healthPermissionGranted {
                  Text("Loading")
              } else {
                  EmptyActivityView()
              }
          }
        .task {
            // TODO look into diff of task vs onAppear?
            guard await health.requestPermission() else {
                healthPermissionGranted = false
                return
            }
            
            // TODO this gets called everytime the screen appears (probably don't need to fetch that frequently
            await health.processWorkouts()
        }
    }
}

#Preview {
    ActivityView()
}

struct EmptyActivityView: View {
    var body: some View {
        Text("Hmmm, it appears I can't find any workout data.")
            .font(.title)
        Text("Please make sure you have recorded a running workout")
        Text("Please make sure you have granted access to read Health data in Settings -> Health -> Data Access & Devices -> Miles")
        Button(action: {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }, label: {
            Text("Settings")
        }).buttonStyle(.borderedProminent)
    }
}

#Preview {
    EmptyActivityView()
}
