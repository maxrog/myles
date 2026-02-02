//
//  ActivityView.swift
//  myles
//
//  Created by Max Rogers on 12/12/23.
//

import SwiftUI
import HealthKit

// TODO look into custom view for refreshable -- have little beating heart

struct ActivityView: View {

    @Environment(HealthManager.self) var health
    @Environment(ShareManager.self) var share

    @State var streakBounce = 0
    @State private var shareImage: UIImage?
    @State private var showShareSheet = false
    @State private var isGeneratingImage = false
    
    private var todaySteps: Double {
        health.steps.first(where: { $0.date.isInSameDay(as: Date())})?.stepCount ?? 0
    }
    
    private var totalDistance: Double {
        let todayRuns = health.runs.filter { $0.startTime.isInSameDay(as: Date()) }
        return health.runsTotalDistance(todayRuns)
    }

    var body: some View {

        let runs = health.runs

        NavigationStack {
            Group {
                if !runs.isEmpty {
                    List {
                        ForEach(runs) { run in
                            Section {
                                RecapView(viewModel: RecapViewModel(health: health,
                                                                              run: run,
                                                                              expanded: run.hasLocationData,
                                                                              showMap: run.hasLocationData))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .listRowInsets(EdgeInsets())
                            } header: {
                                RecapHeaderView(run: run)
                            }
                        }
                    }
                    .refreshable { await health.processWorkouts() }
                } else {
                    EmptyActivityView()
                }
            }
            .toolbar(health.runStreakCount() == 0 && todaySteps == 0 ? .hidden : .visible)
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Share button
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await generateAndShareImage()
                        }
                    } label: {
                        if isGeneratingImage {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.primary)
                        } else {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundStyle(.primary)
                        }
                    }
                    .disabled(isGeneratingImage)
                }
                
                // Streak indicator
                let streak = health.runStreakCount()
                if streak > 0 {
                    ToolbarItem(placement: .topBarLeading) {
                        StreakView(streakCount: streak)
                            .symbolEffect(.bounce, value: streakBounce)
                            .onTapGesture {
                                streakBounce += 1
                                // TODO display something explaining streak - has to be a run with minimum 1 mile
                            }
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let image = shareImage {
                    ShareSheet(items: [image])
                }
            }
        }
    }
    
    /// Generates the activity image and presents the share sheet
    @MainActor
    private func generateAndShareImage() async {
        guard !isGeneratingImage else { return }
        
        isGeneratingImage = true
        
        do {
            // Small delay to allow UI to update
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            
            if let image = await share.generateActivityImage(
                steps: todaySteps,
                distance: totalDistance,
                date: Date()
            ) {
                shareImage = image
                showShareSheet = true
            } else {
                MylesLogger.log(.error, "Failed to generate shareable image", sender: String(describing: self))
            }
        } catch {
            MylesLogger.log(.error, "Error generating image: \(error.localizedDescription)", sender: String(describing: self))
        }
        
        isGeneratingImage = false
    }
}

// MARK: - Share Sheet

/// A UIKit wrapper for presenting the iOS share sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}

#Preview {
    ActivityView()
}
