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
    
    @StateObject private var health = HealthStoreManager.shared
    @State var healthPermissionGranted = true
    
    var body: some View {
        let runs = health.runs
        Group {
            if !runs.isEmpty {
                List(runs) { run in
                    Section {
                        MylesRecapView(run: run)
                    } header: {
                        MylesRecapHeaderView(run: run)
                    }
                }
            } else if healthPermissionGranted {
                Text("Loading")
                    .frame(maxWidth: .infinity)
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
            
            // TODO this gets called everytime the screen appears - should only happen on pull to refresh
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
