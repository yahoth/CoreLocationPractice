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

    @Published var speeds = [Double]()
    @Published var speedKMS: Double = 0

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

    func reset() {
        invalidSpeedAccuracy = 0
        invalidSpeed = 0
        invalidCoordinate = 0
        invalidAltitude = 0
        totalMeasurement = 0
        logs = []
        speeds = []
        speedKMS = 0
    }

    func dateFormatter(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm:ss"
        return formatter.string(from: date)
    }
}

/// test: invalid accuracy를 가진 CLLocation 객체는 모두 부정확할까? 혹은 ex)  speed는 멀쩡한데 horizontal은 부정확할까?
extension AccuracyTestManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        totalMeasurement += 1

        let text = { (string: String) -> String in
                    """
                    ✅number: \(self.totalMeasurement)\n
                    \(string)  / \(self.dateFormatter(date: location.timestamp))\n
                    speed:\(location.speed)\n
                    speedAccuracy: \(location.speedAccuracy)\n
                    horizontal: \(location.horizontalAccuracy)\n
                    vertical: \(location.verticalAccuracy)
                    """
        }

        if location.speed < 0 {
            invalidSpeed += 1
            logs.append(Log(text: text("Speed")))
        }

        if location.speedAccuracy < 0 {
            invalidSpeedAccuracy += 1
            logs.append(Log(text: text("SpeedAccuracy")))
        } else {
            speedKMS = location.speed * 3.6
            speeds.append(location.speed * 3.6)
        }


        if location.horizontalAccuracy < 0 {
            invalidCoordinate += 1
            logs.append(Log(text: text("Coordinate")))
        }

        if location.verticalAccuracy <= 0 {
            invalidAltitude += 1
            logs.append(Log(text: text("Altitude")))
        }

        print("""
              -------------------------------------------------\n
              speedAccuracy: \(String(format: "%.2f", location.speedAccuracy))
              horizontalAccuracy: \(String(format: "%.2f", location.horizontalAccuracy))
              verticalAccuracy: \(String(format: "%.2f", location.verticalAccuracy))
              """)
    }
}
