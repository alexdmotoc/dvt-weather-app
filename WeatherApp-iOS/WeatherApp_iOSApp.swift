//
//  WeatherApp_iOSApp.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 22.08.2023.
//

import SwiftUI
import WeatherApp
import CoreLocation
import CoreData

private let remoteWeatherFetcher: RemoteWeatherFetcher = {
    RemoteWeatherFetcherImpl(client: URLSessionHTTPClient())
}()

private let weatherCache: WeatherCache = {
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

private let weatherViewModel: WeatherViewModel = {
    WeatherViewModel(
        locationManager: CLLocationManager(),
        weatherRepository: WeatherRepositoryImpl(
            fetcher: remoteWeatherFetcher,
            cache: weatherCache
        )
    )
}()

@main
struct WeatherApp_iOSApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: weatherViewModel)
        }
    }
}
