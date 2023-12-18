//
//  MylesRun.swift
//  myles
//
//  Created by Max Rogers on 12/14/23.
//

import Foundation
import CoreLocation

/// A running workout with essential information gathered from HealthStore
struct MylesRun: Identifiable {
    
    /// The unique identifier
    let id: UUID
    /// The start time of the run
    let startTime: Date
    /// The end time of the run
    let endTime: Date
    /// The total duration of the run, in seconds
    let duration: TimeInterval
    /// The total distance of the run, in miles
    let distance: Double
    /// The average heart rate during the run, in beats per minute
    let averageHeartRateBPM: Int?
    /// The total elevation gain and loss of the run, in feet
    let elevationChange: (gain: Int?, loss: Int?)
    /// The average temperature of the run in fahrenheit, and humidity as a percentage
    let weather: (temperature: Int?, humidity: Int?)
    /// The locationPoints of the run - may not have value until requested
    let locationPoints: [CLLocation]?
    var hasLocationData: Bool { locationPoints?.count ?? 0 > 0 }
    
    
    init(id: UUID, startTime: Date, endTime: Date, duration: TimeInterval, distance: Double, averageHeartRateBPM: Double?, elevationChange: (gain: Double?, loss: Double?), weather: (temperature: Double?, humidity: Double?), locationPoints: [CLLocation]?) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.distance = distance
        self.averageHeartRateBPM = Int(averageHeartRateBPM ?? 0)
        self.elevationChange = (Int(elevationChange.gain ?? 0), Int(elevationChange.loss ?? 0))
        self.weather = (Int(weather.temperature ?? 0), Int(weather.humidity ?? 0))
        self.locationPoints = locationPoints
    }
    
    /// The average pace in the common string format mm:ss
    var averagePace: String {
        guard distance > 0 else {
            return ""
        }
        
        let paceInSecondsPerMile = duration / distance
        let minutesPerMile = Int(paceInSecondsPerMile / 60)
        let secondsPerMile = Int(paceInSecondsPerMile.truncatingRemainder(dividingBy: 60))
        
        return String(format: "%02d:%02d", minutesPerMile, secondsPerMile)
    }
}
