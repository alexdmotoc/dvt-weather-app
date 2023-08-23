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
    
    let weatherStore: WeatherInformationStore
    @Published private(set) var isLocationPermissionGranted: Bool
    @Published var isErrorShown: Bool = false
    private(set) var errorMessage: String?
    
    // MARK: - Lifecycle
    
    init(locationManager: LocationManager, useCase: GetWeatherUseCase, weatherStore: WeatherInformationStore) {
        self.locationManager = locationManager
        self.isLocationPermissionGranted = locationManager.isAuthorized
        self.useCase = useCase
        self.weatherStore = weatherStore
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
            let results = try await useCase.getWeather(currentLocation: locationManager.currentLocation?.weatherAppCoordinates) { [weak self] cachedWeather in
                DispatchQueue.main.async {
                    self?.weatherStore.weatherInformation = cachedWeather
                }
            }
            weatherStore.weatherInformation = results
        } catch {
            errorMessage = error.localizedDescription
            isErrorShown = true
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

extension WeatherViewModel {
    /// This is used when first launching the app to have a pleasant UI while the weather for current location is loading
    /// 
    var emptyWeather: WeatherInformation {
        WeatherInformation(
            isCurrentLocation: false,
            location: .init(name: "--", coordinates: .init(latitude: 0, longitude: 0)),
            temperature: .init(current: 0, min: 0, max: 0),
            weatherType: .sunny,
            forecast: []
        )
    }
}
