//
//  LocationManager.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 22.08.2023.
//

import Foundation
import CoreLocation

final class LocationManager: NSObject {
    
    private static let locationDistanceFilter: CLLocationDistance = 5_000 // 5 km
    private let manager: CLLocationManager
    
    private(set) var currentLocation: CLLocation?
    var isAuthorized: Bool { manager.isAuthorized }
    var didChangeAuthorizationStatus: ((Bool) -> Void)?
    var didChangeLocation: ((CLLocation) -> Void)?
    
    init(manager: CLLocationManager) {
        self.manager = manager
        self.currentLocation = manager.location
        super.init()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = Self.locationDistanceFilter
        
        if manager.isAuthorized {
            manager.startUpdatingLocation()
        }
    }
    
    func requestWhenInUseAuthorization() {
        guard !isAuthorized else { return }
        manager.requestWhenInUseAuthorization()
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        didChangeAuthorizationStatus?(manager.isAuthorized)
        if manager.isAuthorized {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var currentLocation = locations[locations.count - 1] // last element is most recent
        if let managerLocation = manager.location, managerLocation.timestamp > currentLocation.timestamp {
            // see docs for `manager.location`
            currentLocation = managerLocation
            manager.stopUpdatingLocation()
            manager.startUpdatingLocation()
        }
        self.currentLocation = currentLocation
        didChangeLocation?(currentLocation)
    }
}
