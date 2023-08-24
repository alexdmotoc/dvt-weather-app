//
//  DIContainer.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 23.08.2023.
//

import Foundation
import WeatherApp
import CoreLocation
import CoreData

@MainActor
enum DIContainer {
    
    private static let remoteWeatherFetcher: RemoteWeatherFetcher = RemoteWeatherFetcherImpl(client: URLSessionHTTPClient())

    private static let weatherCache: WeatherCache = {
        let store: WeatherStore = {
            do {
                return try CoreDataWeatherStore(storeURL: NSPersistentContainer
                    .defaultDirectoryURL()
                    .appendingPathComponent("weather-store.sqlite")
                )
            } catch {
                assertionFailure("Failed to load core data store with error: \(error)")
                return NullWeatherStore()
            }
        }()
        return WeatherCacheImpl(store: store)
    }()

    private static let locationManager = LocationManager(manager: CLLocationManager())

    private static let getWeatherUseCase: GetWeatherUseCase = GetWeatherUseCaseImpl(fetcher: remoteWeatherFetcher, cache: weatherCache)
    
    private static let favouritesUseCase: FavouriteLocationUseCase = FavouriteLocationUseCaseImpl(fetcher: remoteWeatherFetcher, cache: weatherCache)
    
    private static let weatherStore = WeatherInformationStore()
    
    static let appSettings = AppSettings()
    
    @MainActor
    private(set) static var weatherViewModel = WeatherViewModel(
        locationManager: locationManager,
        useCase: getWeatherUseCase,
        weatherStore: weatherStore
    )
    
    static let favouritesViewModel = FavouritesListViewModel(
        store: weatherStore,
        useCase: favouritesUseCase,
        appSettings: appSettings
    )
}
