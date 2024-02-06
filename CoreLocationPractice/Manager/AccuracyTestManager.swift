//
//  AccuracyTestManager.swift
//  CoreLocationPractice
//
//  Created by TAEHYOUNG KIM on 2/7/24.
//

import Foundation
import CoreLocation

class AccuracyTestManager: NSObject {
    let locationManager = CLLocationManager()

    @Published var invalidSpeedAccuracy: Int = 0
    @Published var invalidSpeed: Int = 0
    @Published var invalidCoordinate: Int = 0
    @Published var invalidAltitude: Int = 0
    @Published var totalMeasurement: Int = 0
    @Published var logs = [Log]()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.activityType = .fitness
    }

    func start() {
        locationManager.startUpdatingLocation()
        logs.append(Log(text: "🔥 Start 🔥"))
        print("start")
    }

    func stop() {
        locationManager.stopUpdatingLocation()
        logs.append(Log(text: "🔥 Stop 🔥"))
    }
}

/// test: invalid accuracy를 가진 CLLocation 객체는 모두 부정확할까? 혹은 ex)  speed는 멀쩡한데 horizontal은 부정확할까?
extension AccuracyTestManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        totalMeasurement += 1

        let text =  """
                    number: \(totalMeasurement)\n
                    speed:\(location.speed)\n
                    speedAccuracy: \(location.speedAccuracy)\n
                    horizontal: \(location.horizontalAccuracy)\n
                    vertical: \(location.verticalAccuracy)
                    """

        if location.speed < 0 {
            invalidSpeed += 1
            logs.append(Log(text: "✅✅✅Speed - " + text))
        }

        if location.speedAccuracy < 0 {
            invalidSpeedAccuracy += 1
            logs.append(Log(text: "✅✅✅SpeedAccuracy - " + text))
        }


        if location.horizontalAccuracy < 0 {
            invalidCoordinate += 1
            logs.append(Log(text: "✅✅✅Coordinate - " + text))
        }

        if location.verticalAccuracy <= 0 {
            invalidAltitude += 1
            logs.append(Log(text: "✅✅✅Altitude - " + text))
        }
    }
}
