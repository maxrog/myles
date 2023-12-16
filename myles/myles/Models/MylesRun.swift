//
//  MylesRun.swift
//  myles
//
//  Created by Max Rogers on 12/14/23.
//

import Foundation
import CoreLocation

/// A running workout with essential information from HealthStore
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
    let miles: Double
    /// The average heart rate during the run, in beats per minute
    let averageHeartRateBPM: Double?
    /// The total elevation gain and loss of the run, in feet
    let elevationChange: (gain: Double?, loss: Double?)
    /// The average temperature of the run in fahrenheit, and humidity as a percentage
    let weather: (temperature: Double?, humidity: Double?)
    /// The locationPoints of the run - may not have value until requested
    let locationPoints: [CLLocation]
    
//    
//    func averagePace(durationInSeconds: Double, totalMiles: Double) -> String {
//        guard totalMiles > 0 else {
//            return "Total miles cannot be zero"
//        }
//        
//        let paceInSecondsPerMile = durationInSeconds / totalMiles
//        let minutesPerMile = Int(paceInSecondsPerMile / 60)
//        let secondsPerMile = Int(paceInSecondsPerMile.truncatingRemainder(dividingBy: 60))
//        
//        return String(format: "%02d:%02d per mile", minutesPerMile, secondsPerMile)
//    }
}
