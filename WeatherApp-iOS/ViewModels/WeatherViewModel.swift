//
//  WeatherViewModel.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 22.08.2023.
//

import Foundation
import CoreLocation

final class WeatherViewModel: NSObject, ObservableObject {
    
    // MARK: - Private properties
    
    private static let locationDistanceFilter: CLLocationDistance = 10_000 // 10 km
    private let locationManager: CLLocationManager
    
    // MARK: - Public properties
    
    @Published private(set) var isLocationPermissionGranted: Bool
    
    // MARK: - Lifecycle
    
    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
        self.isLocationPermissionGranted = locationManager.isAuthorized
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = Self.locationDistanceFilter
        
        if locationManager.isAuthorized {
            locationManager.startUpdatingLocation()
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension WeatherViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        isLocationPermissionGranted = manager.isAuthorized
    }
}
