//
//  WeatherViewModel.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 22.08.2023.
//

import Foundation
import CoreLocation
import WeatherApp

@MainActor
final class WeatherViewModel: NSObject, ObservableObject {
    
    // MARK: - Private properties
    
    private let locationManager: LocationManager
    private let useCase: GetWeatherUseCase
    
    
    // MARK: - Public properties
    
    @Published private(set) var isLocationPermissionGranted: Bool
    @Published private(set) var errorMessage: String?
    
    // MARK: - Lifecycle
    
    init(locationManager: LocationManager, useCase: GetWeatherUseCase) {
        self.locationManager = locationManager
        self.isLocationPermissionGranted = locationManager.isAuthorized
        self.useCase = useCase
        super.init()
        setupLocationManager()
    }
    
    // MARK: - Public methods
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    @MainActor
    func getWeather() async {
        do {
            let results = try await useCase.getWeather(currentLocation: locationManager.currentLocation?.weatherAppCoordinates) { cachedWeather in

            }
        } catch {
//            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Private methods
    
    private func setupLocationManager() {
        locationManager.didChangeAuthorizationStatus = { [weak self] isAuthorized in
            self?.isLocationPermissionGranted = isAuthorized
        }
        locationManager.didChangeLocation = { [weak self] _ in
            Task {
                await self?.getWeather()
            }
        }
    }
}

// MARK: - CLLocation + util

private extension CLLocation {
    var weatherAppCoordinates: Coordinates {
        .init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}
