//
//  MylesRun.swift
//  myles
//
//  Created by Max Rogers on 12/14/23.
//

import CoreLocation
import Observation
import HealthKit
import SwiftUI

/*
 TODO refactor naming now that we support more than just a run - hiking, walking, crosstraining too
 */

/// A running workout with essential information gathered from HealthStore
@Observable
class MylesRun: Identifiable, Equatable, Hashable {

    /// The unique identifier
    let id: UUID
    /// The start time of the run
    let startTime: Date
    /// The end time of the run
    let endTime: Date
    /// The type of workout
    let workoutType: MylesWorkoutType
    /// Whether the workout was considered cross training
    var crossTraining: Bool {
        return ![MylesWorkoutType.run, .hike, .walk].contains(self.workoutType)
    }
    /// The environment of the run, indoor or outdoor
    let environment: MylesRunEnvironmentType
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
    var locationPoints: [CLLocation]?
    var hasLocationData: Bool { !(locationPoints?.isEmpty ?? true) }
    /// Whether the run is used to take a spot in the chart
    var emptyPlaceholder: Bool

    static func == (lhs: MylesRun, rhs: MylesRun) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    convenience init(date: Date = Date(), distance: Double = 0.0,
                     duration: TimeInterval = 0.0, emptyPlaceholder: Bool = false) {
        self.init(id: UUID(), startTime: date, endTime: date.addingTimeInterval(duration),
                  workoutType: .running, environment: .outdoor,
                  duration: duration, distance: distance,
                  averageHeartRateBPM: nil, elevationChange: (nil, nil), weather: (nil, nil),
                  emptyPlaceholder: emptyPlaceholder)
    }

    init(id: UUID, startTime: Date, endTime: Date,
         workoutType: HKWorkoutActivityType, environment: MylesRunEnvironmentType,
         duration: TimeInterval, distance: Double,
         averageHeartRateBPM: Double?, elevationChange: (gain: Double?, loss: Double?),
         weather: (temperature: Double?, humidity: Double?),
         locationPoints: [CLLocation]? = nil, mileSplits: [TimeInterval] = [],
         emptyPlaceholder: Bool = false) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.workoutType = MylesWorkoutType(type: workoutType)
        self.environment = environment
        self.duration = duration
        self.distance = distance
        self.averageHeartRateBPM = Int(averageHeartRateBPM ?? 0)
        var elevationGain: Int?
        var elevationLoss: Int?
        if let gain = elevationChange.gain {
            elevationGain = Int(gain)
        }
        if let loss = elevationChange.loss {
            elevationLoss = Int(loss)
        }
        self.elevationChange = (elevationGain, elevationLoss)
        var temperature: Int?
        var humidity: Int?
        if let temp = weather.temperature {
            temperature = Int(temp)
        }
        if let hum = weather.humidity {
            humidity = Int(hum)
        }
        self.weather = (temperature, humidity)
        self.locationPoints = locationPoints
        self.mileSplits = mileSplits
        self.emptyPlaceholder = emptyPlaceholder
    }

    // MARK: Metrics

    /// The duration of the run, in minutes
    var durationMinutes: TimeInterval {
        duration / 60
    }

    /// The average mile pace
    var averageMilePace: TimeInterval {
        duration / distance
    }
    /// The average mile pace in the common string format mm:ss
    var averageMilePaceString: String {
        guard distance > 0 else {
            return ""
        }

        let paceInSecondsPerMile = duration / distance
        let minutesPerMile = Int(paceInSecondsPerMile / 60)
        let secondsPerMile = Int(paceInSecondsPerMile.truncatingRemainder(dividingBy: 60))

        return String(format: "%2d:%02d", minutesPerMile, secondsPerMile)
    }

    /// The splits for pace per mile
    var mileSplits: [TimeInterval] = []
    /// The splits for pace per mile in the common mm:ss format
    var mileSplitStrings: [String] {
        var formattedSplits: [String] = []
        for (index, split) in mileSplits.enumerated() {
            let minutes = Int(split)
            let seconds = Int((split - Double(minutes)) * 60)
            let formattedSplit = String(format: "%d.%2d:%02d", index + 1, minutes, seconds)
            formattedSplits.append(formattedSplit)

        }
        return formattedSplits
    }
}

extension MylesRun {

    /// The image representing the workout type
    var workoutTypeSymbol: Image {
        switch workoutType {
        case .run:
            Image(systemName: "figure.run")
        case .hike:
            Image(systemName: "figure.hiking")
        case .walk:
            Image(systemName: "figure.walk")
        case .cycle:
            Image(systemName: "figure.outdoor.cycle")
        case .row:
            Image(systemName: "figure.rower")
        case .jumpRope:
            Image(systemName: "figure.jumprope")
        case .elliptical:
            Image(systemName: "figure.elliptical")
        case .swim:
            Image(systemName: "figure.pool.swim")
        case .strength:
            Image(systemName: "figure.strengthtraining.traditional")
        case .unknown:
            Image(systemName: "figure.mixed.cardio")
        }
    }

    /// Returns a color to represent the workout type
    var colorForWorkout: Color {
        switch self.workoutType {
        case .run:
            return self.emptyPlaceholder ? Color(.clear) : .mylesLight
        case .hike, .walk:
            return .mylesDark
        default:
            return .cosmicLatte
        }
    }

    /// A test run
    static let testRun = MylesRun(id: UUID(),
                                  startTime: .now.addingTimeInterval(-3700),
                                  endTime: .now,
                                  workoutType: .running,
                                  environment: .outdoor,
                                  duration: 3700,
                                  distance: 8.44443,
                                  averageHeartRateBPM: 135.242332, elevationChange: (600, 200), weather: (75, 90),
                                  locationPoints:
                                    [
                                        CLLocation(latitude: 35.03957863, longitude: -80.94153143),
                                        CLLocation(latitude: 35.02440386, longitude: -80.94729845),
                                        CLLocation(latitude: 35.03643622, longitude: -80.93023495),
                                        CLLocation(latitude: 35.03982536, longitude: -80.94195882),
                                        CLLocation(latitude: 35.03972075, longitude: -80.94186949)
                                    ],
                                  mileSplits: [9.2, 8.4, 7.8, 6.2, 4.9, 4.9, 9.0])

    /// An empty run
    static func emptyRun(date: Date = Date()) -> MylesRun {
        MylesRun(id: UUID(),
                 startTime: date,
                 endTime: date,
                 workoutType: .running,
                 environment: .indoor,
                 duration: 0,
                 distance: 0,
                 averageHeartRateBPM: nil,
                 elevationChange: (nil, nil),
                 weather: (nil, nil),
                 emptyPlaceholder: true)
    }

    /// Snapshot for displaying widget
    static func widgetSnapshotRuns() -> [MylesRun] {
        guard let dates = Calendar.datesForLastWeek() else { return [] }
        var runs: [MylesRun] = []
        for date in dates {
            runs.append(MylesRun(date: date,
                                 distance: Double.random(in: 3.0...8.0),
                                 duration: TimeInterval.random(in: 3000...5000)))
        }
        return runs
    }

}

extension MylesRun: Comparable {
    static func < (lhs: MylesRun, rhs: MylesRun) -> Bool {
        return lhs.distance < rhs.distance
    }
}

/// The environment type of the run, indoor or outdoor
enum MylesRunEnvironmentType {
    case indoor, outdoor
    init(indoor: Bool) {
        self = indoor ? .indoor : .outdoor
    }
}

/// The workout type
enum MylesWorkoutType {
    case run, hike, walk, cycle, row, jumpRope, elliptical, swim, strength, unknown
    init(type: HKWorkoutActivityType) {
        switch type {
        case .running:
            self = .run
        case .hiking:
            self = .hike
        case .walking:
            self = .walk
        case .cycling:
            self = .cycle
        case .rowing:
            self = .row
        case .jumpRope:
            self = .jumpRope
        case .elliptical:
            self = .elliptical
        case .swimming:
            self = .swim
        case .functionalStrengthTraining, .traditionalStrengthTraining:
            self = .strength
        default:
            self = .unknown
        }
    }
}
