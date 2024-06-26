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
 */

extension HealthManager {

    /// Sets up the observer queries for background health data delivery.
    func setUpBackgroundDeliveryForDataTypes() {
        for type in dataTypesToRead() {
            guard let sampleType = type as? HKSampleType else {
                MylesLogger.log(.error, "Failed to cast sample type", sender: String(describing: self))
                continue
            }

            let query = HKObserverQuery(sampleType: sampleType, predicate: nil) { _, completionHandler, error in
                MylesLogger.log(.action, "Observer query update handler called for type \(type), with error \(error?.localizedDescription ?? "nil")", sender: String(describing: self))
                if error == nil {
                    WidgetCenter.shared.reloadAllTimelines()
                    completionHandler()
                }
            }

            store.execute(query)
            store.enableBackgroundDelivery(for: type, frequency: .hourly) { success, error in
                MylesLogger.log(.action,
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
                   HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning) ?? .workoutType(),
                   HKSampleType.quantityType(forIdentifier: .stepCount) ?? .workoutType()
        )
    }
}
