//
//  HealthKitManager.swift
//  myles
//
//  Created by Max Rogers on 12/12/23.
//

import Foundation
import HealthKit
import CoreLocation

// TODO should we store workouts in core data so don't need to fetch everytime? Probably since location thing is heavy

/// Manager for fetching and processing user's health data
class HealthKitManager: ObservableObject {
    
    static let shared = HealthKitManager()
    private init() { }
    
    private let store = HKHealthStore()
    
    @Published var runs: [MylesRun] = []
        
    /// Requests health data access from the user
    func requestPermission() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            Logger.log(.error, "Health data is not available on user's device", sender: String(describing: self))
            return false
        }
        
        let read: Set = [
            .workoutType(),
            HKSeriesType.activitySummaryType(),
            HKSeriesType.workoutType(),
            HKSeriesType.workoutRoute()
        ]
        
        let response: ()? = try? await store.requestAuthorization(toShare: Set<HKSampleType>(), read: read)
        guard response != nil else {
            Logger.log(.error, "Failed to receive user's Health data permission", sender: String(describing: self))
            return false
        }
        
        Logger.log(.action, "User has been prompted for Health data permission", sender: String(describing: self))
        return true
    }
        
    /// Process HealthKit workouts
    /// Query essential metrics including time, duration, distance, and location
    /// Only gathers location for workouts within the last week or last 4 workouts due to expensive fetches
    @MainActor
    func processWorkouts() async {
        Logger.log(.action, "Processing workout data", sender: String(describing: self))
        let workouts = await fetchWorkouts() ?? []
        var runs: [MylesRun] = []
        for (index, workout) in workouts.enumerated() {
            guard let distanceStats = workout.statistics(for: HKQuantityType(.distanceWalkingRunning)),
                  let distanceQuantity = distanceStats.sumQuantity() else { continue }
            let id = workout.uuid
            let startTime = workout.startDate
            let endTime = workout.endDate
            let durationSeconds = workout.duration
            let miles = distanceQuantity.doubleValue(for: .mile())
           
            var heartRateBPM: Double?
            if let heartRateStats = workout.statistics(for: HKQuantityType(.heartRate)),
               let heartRateQuantity = heartRateStats.averageQuantity() {
                heartRateBPM = heartRateQuantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
            }
            
            var elevationGain: Double?
            var elevationLoss: Double?
            var weatherTemp: Double?
            var weatherHumidity: Double?
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
                
            }
            
            
            let routes = await fetchWorkoutRoutes(for: workout) ?? []
            var locationPoints: [CLLocation] = []
            
            // Don't fetch ALL workout location data as it is expensive
            // Rather, gather the last week or last 4 workouts
            if workout.endDate.daysBetween(Date()) <= 7 || index <= 4 {
                for route in routes {
                    await locationPoints.append(contentsOf: fetchLocationData(for: route))
                }
            }
            
            let run = MylesRun(id: id,
                               startTime: startTime,
                               endTime: endTime,
                               duration: durationSeconds,
                               miles: miles,
                               averageHeartRateBPM: heartRateBPM,
                               elevationChange: (elevationGain, elevationLoss),
                               weather: (weatherTemp, weatherHumidity),
                               locationPoints: locationPoints)
            runs.append(run)
        }
        Logger.log(.success, "Successfully processed \(runs.count) running workouts", sender: String(describing: self))
        self.runs = runs
    }
}


// MARK: Queries

extension HealthKitManager {
    
    /// Fetches a list of workouts
    /// - Parameters:
    ///   - type: The activity type to query
    /// - Returns: The matching workouts
    private func fetchWorkouts(type: HKWorkoutActivityType = .running) async -> [HKWorkout]? {
        let workoutPredicate = HKQuery.predicateForWorkouts(with: type)
        
        let samples = try? await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
            store.execute(HKSampleQuery(sampleType: .workoutType(), predicate: workoutPredicate, limit: HKObjectQueryNoLimit, sortDescriptors: [.init(keyPath: \HKSample.startDate, ascending: false)], resultsHandler: { query, samples, error in
                if let error = error {
                    Logger.log(.error, "Failed to retrieve workout samples, \(error.localizedDescription)", sender: String(describing: self))
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let samples = samples else {
                    Logger.log(.error, "Failed to retrieve workout samples, returning empty", sender: String(describing: self))
                    continuation.resume(returning: [])
                    return
                }
                
                continuation.resume(returning: samples)
            }))
        }
        
        guard let workouts = samples as? [HKWorkout], workouts.count > 0 else {
            Logger.log(.error, "Failed to retrieve workouts, returning empty", sender: String(describing: self))
            return nil
        }
        
        Logger.log(.success, "Successfully retrieved \(workouts.count) workouts", sender: String(describing: self))
        return workouts
    }
    
    /// Fetches associated routes from a workout
    /// - Parameters:
    ///   - workout: The workout for desired routes
    /// - Returns: The matching routes, if available
    private func fetchWorkoutRoutes(for workout: HKWorkout) async -> [HKWorkoutRoute]? {
        let byWorkout = HKQuery.predicateForObjects(from: workout)
        
        let samples = try? await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
            store.execute(HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: byWorkout, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: { (query, samples, deletedObjects, anchor, error) in
                if let error = error {
                    Logger.log(.error, "Failed to retrieve route samples, \(error.localizedDescription)", sender: String(describing: self))
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let samples = samples else {
                    Logger.log(.error, "Failed to retrieve route samples, returning empty", sender: String(describing: self))
                    continuation.resume(returning: [])
                    return
                }
                
                continuation.resume(returning: samples)
            }))
        }
        
        guard let workoutRoutes = samples as? [HKWorkoutRoute] else {
            Logger.log(.error, "Failed to retrieve workout routes, returning empty", sender: String(describing: self))
            return nil
        }
        
        Logger.log(.success, "Successfully retrieved \(workoutRoutes.count) workout routes", sender: String(describing: self))
        return workoutRoutes
    }
    
    /// Fetches associated location data from a workout rout
    /// - Parameters:
    ///   - route: The route for desired location data
    /// - Returns: The location data, if available
    private func fetchLocationData(for route: HKWorkoutRoute) async -> [CLLocation] {
        let locations = try? await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[CLLocation], Error>) in
            var allLocations: [CLLocation] = []
            let query = HKWorkoutRouteQuery(route: route) {  (query, locations, finished, error) in
                
                if let error = error {
                    Logger.log(.error, "Failed to retrieve route location data, \(error.localizedDescription)", sender: String(describing: self))
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let currentLocationBatch = locations else {
                    Logger.log(.error, "Failed to retrieve route location batch, returning empty", sender: String(describing: self))
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
            Logger.log(.error, "Failed to retrieve route location data, returning empty", sender: String(describing: self))
            return []
        }
        
        Logger.log(.success, "Successfully retrieved \(locations.count) location objects", sender: String(describing: self))
        return locations
    }
}

