//
//  LocationManager.swift
//  CoreLocationPractice
//
//  Created by TAEHYOUNG KIM on 1/31/24.
//

import Foundation
import CoreLocation
import Combine

struct Log: Hashable {
    let id: UUID = UUID()
    let text: String
}

class LocationManager: NSObject {
    let locationManager = CLLocationManager()
    @Published var logs: [Log] = []
    @Published var region: CLCircularRegion?
    var subscriptions = Set<AnyCancellable>()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    func start() {
        let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 37.33497685282217, longitude: -122.04664142846063), radius: 500, identifier: "Homestead High School")
        self.region = region
        monitorRegionAtLocation(region: region)
    }

    func monitorRegionAtLocation(region: CLCircularRegion) {
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            region.notifyOnEntry = true
            region.notifyOnExit = true
            locationManager.startMonitoring(for: region)
            logs.append(Log(text: "*** Start Monitoring ***"))
        }
    }

    func stop() {
        logs.append(Log(text: "*** Stop Monitoring ***"))
        locationManager.stopMonitoring(for: region ?? CLCircularRegion())
        region = nil
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let region = region as? CLCircularRegion {
            let identifier = region.identifier
            logs.append(Log(text: "Enter region: \(identifier)"))
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let region = region as? CLCircularRegion {
            let identifier = region.identifier
            logs.append(Log(text: "Exit region: \(identifier)"))
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logs.append(Log(text: error.localizedDescription))
    }
}
