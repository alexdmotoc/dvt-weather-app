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
    private let defaults: UserDefaults
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    private static let lastUpdatedKey = "com.weatherViewModel.lastUpdated"
    private var isGettingWeather: Bool = false
    
    // MARK: - Public properties
    
    let weatherStore: WeatherInformationStore
    @Published private(set) var isLocationPermissionGranted: Bool
    @Published private(set) var lastUpdated: String
    @Published var isErrorShown: Bool = false
    private(set) var errorMessage: String?
    
    // MARK: - Lifecycle
    
    init(
        locationManager: LocationManager,
        useCase: GetWeatherUseCase,
        weatherStore: WeatherInformationStore,
        defaults: UserDefaults = .standard
    ) {
        self.locationManager = locationManager
        self.isLocationPermissionGranted = locationManager.isAuthorized
        self.useCase = useCase
        self.weatherStore = weatherStore
        self.defaults = defaults
        self.lastUpdated = Self.makeLastUpdatedString(
            date: defaults.object(forKey: Self.lastUpdatedKey) as? Date,
            formatter: formatter
        )
        super.init()
        setupLocationManager()
    }
    
    // MARK: - Public methods
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    @MainActor
    func getWeather() async {
        guard !isGettingWeather else { return }
        isGettingWeather = true
        do {
            let coord = locationManager.currentLocation?.coordinate.weatherAppCoordinates
            let results = try await useCase.getWeather(currentLocation: coord) { [weak self] cachedWeather in
                DispatchQueue.main.async {
                    self?.weatherStore.weatherInformation = cachedWeather
                }
            }
            weatherStore.weatherInformation = results
            defaults.set(Date(), forKey: Self.lastUpdatedKey)
            lastUpdated = Self.makeLastUpdatedString(date: Date(), formatter: formatter)
        } catch {
            errorMessage = error.localizedDescription
            isErrorShown = true
        }
        isGettingWeather = false
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
    
    private static func makeLastUpdatedString(date: Date?, formatter: DateFormatter) -> String {
        func lastUpdated(value: String) -> String {
            String(format: NSLocalizedString("lastUpdated.format", comment: ""), value)
        }
        guard let date else {
            return lastUpdated(value: "--")
        }
        return lastUpdated(value: formatter.string(from: date))
    }
}

// MARK: - Utils

extension WeatherViewModel {
    /// This is used when first launching the app to have a pleasant UI while
    /// the weather for current location is loading
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
