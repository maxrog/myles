//
//  HealthManager+Background.swift
//  myles
//
//  Created by Max Rogers on 2/9/24.
//

import HealthKit
import WidgetKit

/*
 HealthKit background management
 TODO add logging
 */

extension HealthManager {
    
    /// Sets up the observer queries for background health data delivery.
    func setUpBackgroundDeliveryForDataTypes() {
        for type in dataTypesToRead() {
            guard let sampleType = type as? HKSampleType else {
                Logger.log(.error, "Failed to cast sample type", sender: String(describing: self))
                continue
            }
            
            let query = HKObserverQuery(sampleType: sampleType, predicate: nil) { query, completionHandler, error in
                Logger.log(.action, "Observer query update handler called for type \(type)", sender: String(describing: self))
                WidgetCenter.shared.reloadAllTimelines()
                completionHandler()
            }

            store.execute(query)
            store.enableBackgroundDelivery(for: type, frequency: .immediate) { success, error in
                Logger.log(.action, 
                           "enableBackgroundDeliveryForType handler called for type \(type) - success \(success), error: \(error?.localizedDescription ?? "nil")",
                           sender: String(describing: self))
            }
        }
    }
    /// Types of data that this app wishes to read from HealthKit.
    ///
    /// - returns: A set of HKObjectType.
    private func dataTypesToRead() -> Set<HKObjectType> {
        return Set(arrayLiteral:
                .workoutType(),
                   HKSeriesType.activitySummaryType(),
                   HKSeriesType.workoutType(),
                   HKSeriesType.workoutRoute(),
                   HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!
        )
    }
}
