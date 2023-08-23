//
//  WeatherViewModel.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 22.08.2023.
//

import Foundation
import CoreLocation
import WeatherApp

final class WeatherViewModel: NSObject, ObservableObject {
    
    // MARK: - Private properties
    
    private static let locationDistanceFilter: CLLocationDistance = 10_000 // 10 km
    private let locationManager: CLLocationManager
    private let weatherRepository: WeatherRepository
    private var currentLocation: CLLocation?
    
    // MARK: - Public properties
    
    @Published private(set) var isLocationPermissionGranted: Bool
    @Published private(set) var errorMessage: String?
    
    // MARK: - Lifecycle
    
    init(locationManager: CLLocationManager, weatherRepository: WeatherRepository) {
        self.locationManager = locationManager
        self.isLocationPermissionGranted = locationManager.isAuthorized
        self.currentLocation = locationManager.location
        self.weatherRepository = weatherRepository
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = Self.locationDistanceFilter
        
        if locationManager.isAuthorized {
            locationManager.startUpdatingLocation()
        }
    }
    
    // MARK: - Public methods
    
    func requestLocationPermission() {
        guard !locationManager.isAuthorized else { return }
        locationManager.requestWhenInUseAuthorization()
    }
    
    @MainActor
    func getWeather() async {
        do {
            let results = try await weatherRepository.getWeather(currentLocation: currentLocation?.weatherAppCoordinates) { cachedWeather in

            }
        } catch {
//            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension WeatherViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        isLocationPermissionGranted = manager.isAuthorized
        
        if manager.isAuthorized {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
}


// MARK: - CLLocation + util

private extension CLLocation {
    var weatherAppCoordinates: Coordinates {
        .init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}
