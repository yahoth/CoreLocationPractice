//
//  CLLocationUpdateManager.swift
//  CoreLocationPractice
//
//  Created by TAEHYOUNG KIM on 2/1/24.
//

import Foundation
import CoreLocation

class CLLocationUpdateManager {
    var updates: CLLocationUpdate.Updates?

    init() {
        updates = CLLocationUpdate.liveUpdates()
        guard let updates else {
            print("no updates")
            return
        }
        Task {
            for try await update in updates {
                print("my location is \(String(describing: update.location))")
            }
        }
    }
}
