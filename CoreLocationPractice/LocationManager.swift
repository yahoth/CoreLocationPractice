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
        locationManager.startMonitoringVisits()
        logs.append(Log(text: "*** Start MonitoringVisits ***"))
    }

    func stop() {
        locationManager.stopMonitoringVisits()
        logs.append(Log(text: "*** Start MonitoringVisits ***"))

    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        if visit.departureDate == Date.distantPast {
            logs.append(Log(text: "방문 시작: \(visit.arrivalDate)"))
        } else {
            logs.append(Log(text: "방문 종료: \(visit.departureDate)"))
        }
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        logs.append(Log(text: error.localizedDescription))
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logs.append(Log(text: error.localizedDescription))
    }
}
