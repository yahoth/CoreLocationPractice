//
//  LocationManager.swift
//  CoreLocationPractice
//
//  Created by TAEHYOUNG KIM on 1/31/24.
//

import Foundation
import CoreLocation

struct Log: Hashable {
    let id: UUID = UUID()
    let text: String
}

class LocationManager: NSObject {
    let locationManager = CLLocationManager()
    var previousLocation: CLLocation?
    @Published var logs: [Log] = []

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
    }

    func start() {
        locationManager.startUpdatingHeading()
        logs.append(Log(text: "*** Start updating Heading ***"))
    }

    func stop() {
        locationManager.stopUpdatingHeading()
        logs.append(Log(text: "*** Stop updating Heading ***"))
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        var heading: String = ""

        if newHeading.trueHeading > 45 && newHeading.trueHeading <= 135 {
            heading = "동쪽"
        } else if newHeading.trueHeading > 135 && newHeading.trueHeading <= 225 {
            heading = "남쪽"
        } else if newHeading.trueHeading > 225 && newHeading.trueHeading <= 315 {
            heading = "서쪽"
        } else {
            heading = "북쪽"
        }

        if logs.last?.text != heading {
            logs.append(Log(text: "\(heading)"))
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logs.append(Log(text: error.localizedDescription))
    }
}
