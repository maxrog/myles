//
//  ActivityView.swift
//  myles
//
//  Created by Max Rogers on 12/12/23.
//

import SwiftUI
import HealthKit

// TODO - don't load all 1K or w/e activities, load say, last 2-3 months and only load more as scroll down screen

struct ActivityView: View {
    
    @StateObject private var health = HealthKitManager.shared
    @State var healthPermissionGranted = true
    
    var body: some View {
        GeometryReader { geo in
            if health.runs.count > 0 {
                List(health.runs) { run in
                    if run.hasLocationData {
                        VStack {
                            HStack {
                                MylesMapView(run: run)
                                    .frame(width: geo.size.width / 2.5)
                                    .clipShape(.rect(cornerSize: CGSize(width: 8, height: 8)))
                                VStack {
                                    Text("\(run.distance.prettyString) mi")
                                        .font(.largeTitle)
                                    Text(run.startTime.shortCalendarDateFormat)
                                        .font(.headline)
                                    Text(run.startTime.shortDayOfWeekDateFormat)
                                    Text("Pace: \(run.averagePace)")
                                }
                            }
                            // TODO icons isntead of text for labels
                            HStack {
                                Text("\(run.duration.prettyTimeString)")
                                    .font(.footnote)
                                Text("BPM \(run.averageHeartRateBPM ?? 0)")
                                    .font(.footnote)
                                Text("Gain \(run.elevationChange.gain ?? 0) ft")
                                    .font(.footnote)
                                Text("Temp \(run.weather.temperature ?? 0) F")
                                    .font(.footnote)
                                Text("Hum \(run.weather.humidity ?? 0) %")
                                    .font(.footnote)
                            }
                        }
                    } else {
                        VStack {
                            Text("\(run.distance.prettyString) mi")
                                .font(.largeTitle)
                            Text(run.startTime.shortCalendarDateFormat)
                                .font(.headline)
                            Text(run.startTime.shortDayOfWeekDateFormat)
                            Text("Pace: \(run.averagePace)")
                            HStack {
                                Text("\(run.duration.prettyTimeString)")
                                    .font(.footnote)
                                Text("BPM \(run.averageHeartRateBPM ?? 0)")
                                    .font(.footnote)
                                Text("Gain \(run.elevationChange.gain ?? 0) ft")
                                    .font(.footnote)
                                Text("Temp \(run.weather.temperature ?? 0) F")
                                    .font(.footnote)
                                Text("Hum \(run.weather.humidity ?? 0) %")
                                    .font(.footnote)
                            }
                        }
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
