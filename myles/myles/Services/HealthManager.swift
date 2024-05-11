//
//  HealthManager.swift
//  myles
//
//  Created by Max Rogers on 12/12/23.
//

import Foundation
import HealthKit
import CoreLocation
import SwiftUI
import Observation

// TODO algorithm for grouping by weeks Monday-Sunday
// TODO Cross training - get workouts that aren't runs and show them with a different color line for stats (base off of duration - 10 ~= 1 mile)

/// Manager for fetching and processing user's health data
@Observable
class HealthManager {
        
    init() { }
    
    let goals = GoalsManager.shared
    let store = HKHealthStore()

    /// HKWorkouts that back our data model
    private var storedWorkouts: [HKWorkout] = []
    
    var runs: [MylesRun] = []
    var dailySteps: Double = 0.0
    private var setupBackgroundDelivery = false
    
    /// Requests health data access from the user
    func requestPermission() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            MylesLogger.log(.error, "Health data is not available on user's device", sender: String(describing: self))
            return false
        }
        
        let read: Set = [
            .workoutType(),
            HKSeriesType.activitySummaryType(),
            HKSeriesType.workoutType(),
            HKSeriesType.workoutRoute(),
            HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning) ?? .workoutType(),
            HKSampleType.quantityType(forIdentifier: .stepCount) ?? .workoutType()
        ]
        
        let response: ()? = try? await store.requestAuthorization(toShare: Set<HKSampleType>(), read: read)
        guard response != nil else {
            MylesLogger.log(.error, "Failed to receive user's Health data permission", sender: String(describing: self))
            return false
        }
        MylesLogger.log(.action, "User has been prompted for Health data permission", sender: String(describing: self))
        return true
    }
    
    // TODO Make sure this doesn't get spam triggered
    /// Process HealthKit workouts
    /// Query essential metrics including time, duration, distance, and location
    /// Only gathers location for workouts within the last week or last 4 workouts due to expensive fetches
    /// - Parameters:
    ///   - startDate: The date in which to begin looking for workouts
    ///   - limit: The limit to number of activities to query
    /// @MainActor
    @MainActor
    func processWorkouts(startDate: Date? = nil, limit: Int = HKObjectQueryNoLimit) async {
        MylesLogger.log(.action, "Processing workout data", sender: String(describing: self))
        self.dailySteps = await fetchDailySteps()
        let runningWorkouts = await fetchWorkouts(type: .running, startDate: startDate, limit: limit) ?? []
        let hikingWorkouts = await fetchWorkouts(type: .hiking, startDate: startDate, limit: limit) ?? []
        let walkingWorkouts = await fetchWorkouts(type: .walking, startDate: startDate, limit: limit) ?? []
        var crossTrainWorkouts: [HKWorkout] = []
        for type in [HKWorkoutActivityType.cycling,
                     HKWorkoutActivityType.rowing,
                     HKWorkoutActivityType.jumpRope,
                     HKWorkoutActivityType.elliptical,
                     HKWorkoutActivityType.swimming, 
                     HKWorkoutActivityType.functionalStrengthTraining,
                     HKWorkoutActivityType.traditionalStrengthTraining] {
            crossTrainWorkouts.append(contentsOf: await fetchWorkouts(type: type, startDate: startDate, limit: limit) ?? [])
        }
        
        let workouts = (runningWorkouts + hikingWorkouts + walkingWorkouts + crossTrainWorkouts).sorted(by:{$0.endDate > $1.endDate })
        var runs: [MylesRun] = []
        for (index, workout) in workouts.enumerated() {
            let distanceStats = workout.statistics(for: HKQuantityType(.distanceWalkingRunning))
            ?? workout.statistics(for: HKQuantityType(.distanceCycling))
            ?? workout.statistics(for: HKQuantityType(.distanceSwimming))
            let distanceQuantity = distanceStats?.sumQuantity()
            let id = workout.uuid
            let startTime = workout.startDate
            let endTime = workout.endDate
            let durationSeconds = workout.duration
            // TODO should we or maybe setting for non mileage cross train to mile conversion?
            let miles = distanceQuantity?.doubleValue(for: .mile()) ?? 0.0
            
            var heartRateBPM: Double?
            if let heartRateStats = workout.statistics(for: HKQuantityType(.heartRate)),
               let heartRateQuantity = heartRateStats.averageQuantity() {
                heartRateBPM = heartRateQuantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
            }
            
            var elevationGain: Double?
            var elevationLoss: Double?
            var weatherTemp: Double?
            var weatherHumidity: Double?
            var indoorWorkout = true
            if let workoutMetadata = workout.metadata {
                if let elevationGainQuantity = workoutMetadata["HKElevationAscended"] as? HKQuantity {
                    elevationGain = elevationGainQuantity.doubleValue(for: HKUnit.foot())
                }
                if let elevationLossQuantity = workoutMetadata["HKElevationDescended"] as? HKQuantity {
                    elevationLoss = elevationLossQuantity.doubleValue(for: HKUnit.foot())
                }
                
                if let tempQuantity = workoutMetadata["HKWeatherTemperature"] as? HKQuantity {
                    weatherTemp = tempQuantity.doubleValue(for: .degreeFahrenheit())
                }
                if let humidityQuantity = workoutMetadata["HKWeatherHumidity"] as? HKQuantity {
                    weatherHumidity = humidityQuantity.doubleValue(for: .percent())
                }
                
                if let indoor = workoutMetadata["HKIndoorWorkout"] as? Bool {
                    indoorWorkout = indoor
                }
            }
            
            var locationPoints: [CLLocation]?
            var splits: [TimeInterval] = []
            
            // Don't fetch all workout data as it is expensive
            // Rather, gather the first workout and let user request more as needed
            if index == 0 {
                let routes = await fetchWorkoutRoutes(for: workout) ?? []
                locationPoints = []
                for route in routes {
                    await locationPoints?.append(contentsOf: fetchLocationData(for: route))
                }
                splits = await calculateMileSplits(startTime: startTime, endTime: endTime)
            }
            
            let run = MylesRun(id: id,
                               startTime: startTime,
                               endTime: endTime, 
                               workoutType: workout.workoutActivityType,
                               environment: MylesRunEnvironmentType(indoor: indoorWorkout),
                               duration: durationSeconds,
                               distance: miles,
                               averageHeartRateBPM: heartRateBPM,
                               elevationChange: (elevationGain, elevationLoss),
                               weather: (weatherTemp, weatherHumidity),
                               locationPoints: locationPoints,
                               mileSplits: splits)
            runs.append(run)
        }
        MylesLogger.log(.success, "Successfully processed \(runs.count) running workouts", sender: String(describing: self))
        if !runs.isEmpty && !setupBackgroundDelivery {
            self.setUpBackgroundDeliveryForDataTypes()
            setupBackgroundDelivery = true
        }
        self.runs = runs
    }
    
    /// Processes map data for single run
    /// Since we don't want to process all on launch, we lazy load maps at user request
    /// - Returns: Bool indicating if the workout had location data available
    /// @MainActor
    @MainActor
    public func loadMapData(for run: MylesRun) async -> Bool {
        let id = run.id
        guard let locationPoints = await fetchWorkoutLocationData(for: id), locationPoints.count > 0 else {
            MylesLogger.log(.action, "Run \(run.id) does not contain location data", sender: String(describing: self))
            return false
        }
        withAnimation {
            run.locationPoints = locationPoints
        }
        MylesLogger.log(.success, "Run \(run.id) successfully updated with \(locationPoints.count) location points", sender: String(describing: self))
        return true
    }
}


// MARK: Queries

extension HealthManager {
    
    /// Fetches a list of workouts
    /// - Parameters:
    ///   - type: The activity type to query
    ///   - startDate: The date in which to begin looking for workouts
    ///   - limit: The limit to number of activities to query
    /// - Returns: The matching workouts
    private func fetchWorkouts(type: HKWorkoutActivityType = .running, startDate: Date? = nil, limit: Int = HKObjectQueryNoLimit) async -> [HKWorkout]? {
        var predicates = [HKQuery.predicateForWorkouts(with: type)]
        if let startDate = startDate {
            predicates.append(HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate))
        }
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)

        let samples = try? await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
            store.execute(HKSampleQuery(sampleType: .workoutType(), predicate: compoundPredicate, limit: limit, sortDescriptors: [.init(keyPath: \HKSample.startDate, ascending: false)], resultsHandler: { query, samples, error in
                if let error = error {
                    MylesLogger.log(.error, "Failed to retrieve workout samples, \(error.localizedDescription)", sender: String(describing: self))
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let samples = samples else {
                    MylesLogger.log(.error, "Failed to retrieve workout samples, returning empty", sender: String(describing: self))
                    continuation.resume(returning: [])
                    return
                }
                
                continuation.resume(returning: samples)
            }))
        }
        
        guard let workouts = samples as? [HKWorkout], workouts.count > 0 else {
            MylesLogger.log(.error, "Failed to retrieve workouts, returning empty", sender: String(describing: self))
            return nil
        }
        
        MylesLogger.log(.success, "Successfully retrieved \(workouts.count) workouts", sender: String(describing: self))
        self.storedWorkouts = workouts
        return workouts
    }
    
    /// Fetches associated routes from a workout
    /// - Parameters:
    ///   - workout: The workout for desired routes
    /// - Returns: The matching routes, if available
    private func fetchWorkoutRoutes(for workout: HKWorkout) async -> [HKWorkoutRoute]? {
        MylesLogger.log(.action, "Attemping to fetch workout routes for workout \(workout.uuid.uuidString)", sender: String(describing: self))
        
        let byWorkout = HKQuery.predicateForObjects(from: workout)
        let samples = try? await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
            store.execute(HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: byWorkout, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: { (query, samples, deletedObjects, anchor, error) in
                if let error = error {
                    MylesLogger.log(.error, "Failed to retrieve route samples, \(error.localizedDescription)", sender: String(describing: self))
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let samples = samples else {
                    MylesLogger.log(.error, "Failed to retrieve route samples, returning empty", sender: String(describing: self))
                    continuation.resume(returning: [])
                    return
                }
                
                continuation.resume(returning: samples)
            }))
        }
        
        guard let workoutRoutes = samples as? [HKWorkoutRoute] else {
            MylesLogger.log(.error, "Failed to retrieve workout routes, returning empty", sender: String(describing: self))
            return nil
        }
        
        MylesLogger.log(.success, "Successfully retrieved \(workoutRoutes.count) workout routes", sender: String(describing: self))
        return workoutRoutes
    }
    
    /// Fetches associated location data from a workout rout
    /// - Parameters:
    ///   - route: The route for desired location data
    /// - Returns: The location data, if available
    private func fetchLocationData(for route: HKWorkoutRoute) async -> [CLLocation] {
        MylesLogger.log(.action, "Attemping to fetch workout locations for route \(route.uuid.uuidString)", sender: String(describing: self))
        let locations = try? await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[CLLocation], Error>) in
            var allLocations: [CLLocation] = []
            let query = HKWorkoutRouteQuery(route: route) {  (query, locations, finished, error) in
                
                if let error = error {
                    MylesLogger.log(.error, "Failed to retrieve route location data, \(error.localizedDescription)", sender: String(describing: self))
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let currentLocationBatch = locations else {
                    MylesLogger.log(.error, "Failed to retrieve route location batch, returning empty", sender: String(describing: self))
                    continuation.resume(returning: [])
                    return
                }
                
                allLocations.append(contentsOf: currentLocationBatch)
                
                if finished {
                    continuation.resume(returning: allLocations)
                }
            }
            store.execute(query)
        }
        
        guard let locations = locations else {
            MylesLogger.log(.error, "Failed to retrieve route location data, returning empty", sender: String(describing: self))
            return []
        }
        
        MylesLogger.log(.success, "Successfully retrieved \(locations.count) location points", sender: String(describing: self))
        return locations
    }
    
    
    /// Fetches workout location data for a single workout
    /// - Parameters:
    ///   - id: The workout's id to query
    /// - Returns: The matching workout's location data
    private func fetchWorkoutLocationData(for id: UUID) async -> [CLLocation]? {
        let workoutPredicate = HKQuery.predicateForObject(with: id)
        
        let samples = try? await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
            store.execute(HKSampleQuery(sampleType: .workoutType(), predicate: workoutPredicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil, resultsHandler: { query, samples, error in
                if let error = error {
                    MylesLogger.log(.error, "Failed to retrieve workout, \(error.localizedDescription)", sender: String(describing: self))
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let samples = samples else {
                    MylesLogger.log(.error, "Failed to retrieve workout sample with id \(id.uuidString), returning empty", sender: String(describing: self))
                    continuation.resume(returning: [])
                    return
                }
                
                continuation.resume(returning: samples)
            }))
        }
        
        guard let workout = (samples as? [HKWorkout])?.first else {
            MylesLogger.log(.error, "Failed to retrieve workout with id \(id.uuidString), returning empty", sender: String(describing: self))
            return nil
        }
        
        MylesLogger.log(.success, "Successfully retrieved workout \(workout.uuid.uuidString)", sender: String(describing: self))
        
        var locationPoints: [CLLocation]?
        let routes = await fetchWorkoutRoutes(for: workout) ?? []
        locationPoints = []
        for route in routes {
            await locationPoints?.append(contentsOf: fetchLocationData(for: route))
        }
        
        return locationPoints
    }
    
    // TODO figure out how to account for user pausing the workout - ask chat gpt
    /// Fetches workout data & calculates split times for a single workout
    /// - Parameters:
    ///   - startTime: The start time of the workout
    ///   - endTime: The end time of the workout
    /// - Returns: An array of splits per mile in minutes
    func calculateMileSplits(startTime: Date, endTime: Date) async -> [TimeInterval] {
        let distanceType = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)
        let predicate = HKQuery.predicateForSamples(withStart: startTime, end: endTime, options: .strictStartDate)

        let samples = try? await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
            store.execute(HKSampleQuery(sampleType: distanceType!, predicate: predicate,
                                        limit: HKObjectQueryNoLimit, sortDescriptors: [.init(keyPath: \HKSample.startDate, ascending: true)], resultsHandler: { (query, samples, error) -> Void in
                if let error = error {
                    MylesLogger.log(.error, "Failed to retrieve workout distance samples, \(error.localizedDescription)", sender: String(describing: self))
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let samples = samples else {
                    MylesLogger.log(.error, "Failed to retrieve workout distance samples, returning empty", sender: String(describing: self))
                    continuation.resume(returning: [])
                    return
                }
                
                continuation.resume(returning: samples)
            }))
        }
        
        guard let samples = samples as? [HKQuantitySample] else {
            MylesLogger.log(.error, "Failed to retrieve workout distance samples, returning empty", sender: String(describing: self))
            return []
        }
        
        var totalDistance: Double = 0.0
        var totalTime: TimeInterval = 0.0
        var mileSplits: [TimeInterval] = []
        
        MylesLogger.log(.action, "Processing mile splits", sender: String(describing: self))

        for sample in samples {
            totalDistance += sample.quantity.doubleValue(for: HKUnit.meter())
            totalTime += sample.endDate.timeIntervalSince(sample.startDate)
            
            // Calculate mile splits
            if totalDistance >= 1609.34 { // Check if distance covered is at least a mile
                let mileSplit = totalTime / 60.0 // Assuming you want the split in minutes
                mileSplits.append(mileSplit)
                totalDistance -= 1609.34 // Subtract a mile from totalDistance
                totalTime = 0.0 // Reset time for the next mile
            }
        }
        
        MylesLogger.log(.action, "Processed and returning mile splits for \(mileSplits.count) miles", sender: String(describing: self))
        
        return mileSplits
    }
    
    /// Returns the number of steps for today
    func fetchDailySteps() async -> Double {
        guard let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return 0.0 }
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        do {
            return try await withCheckedThrowingContinuation { continuation in
                let query = HKStatisticsQuery(
                    quantityType: stepsQuantityType,
                    quantitySamplePredicate: predicate,
                    options: .cumulativeSum
                ) { _, result, error in
                    guard let result = result, let sum = result.sumQuantity() else {
                        MylesLogger.log(.error, "Error fetching daily steps - \(error?.localizedDescription ?? "")", sender: String(describing: self))
                        continuation.resume(returning: 0.0)
                        return
                    }
                    let stepCount = sum.doubleValue(for: HKUnit.count())
                    MylesLogger.log(.success, "Successfully fetched \(stepCount) daily steps", sender: String(describing: self))
                    continuation.resume(returning: sum.doubleValue(for: HKUnit.count()))
                }
                store.execute(query)
            }
        } catch let error {
            MylesLogger.log(.error, "Error fetching daily steps - \(error.localizedDescription)", sender: String(describing: self))
            return 0.0
        }
    }
    
}

