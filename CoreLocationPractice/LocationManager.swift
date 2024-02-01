//
//  LocationManager.swift
//  CoreLocationPractice
//
//  Created by TAEHYOUNG KIM on 1/31/24.
//

import Foundation
import CoreLocation

class LocationManager: NSObject {
    let locationManager = CLLocationManager()
    var previousLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    func start() {
        print("*** Start Updating Location ***\n")
        locationManager.startUpdatingLocation()
    }

    func stop() {
        print("*** Stop Updating Location ***")
        locationManager.stopUpdatingLocation()

    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let coordinate = location.coordinate
        let speed = location.speed
        let horizontalAccuracy = location.horizontalAccuracy
        let speedAccuracy = location.speedAccuracy
        print("--------------------------------------------------------------------------------------\n")
        print("Coordinate: \(coordinate), accuracy: \(horizontalAccuracy)\n")
        print("Speed: \(Int(speed))M, accuracy: \(speedAccuracy)\n")
        if let previousLocation {
            let time = location.timestamp.timeIntervalSince(previousLocation.timestamp)
            print("period: \(time)")
        }
        previousLocation = location
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
