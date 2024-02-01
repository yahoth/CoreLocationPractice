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
        logs.append(Log(text: "*** Start updating Heading ***"))

    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {

        logs.append(Log(text: "\(-newHeading.trueHeading * Double.pi / 180)"))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logs.append(Log(text: error.localizedDescription))
    }
}
