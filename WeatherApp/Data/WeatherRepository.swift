//
//  WeatherRepository.swift
//  WeatherApp
//
//  Created by Alex Motoc on 21.08.2023.
//

import Foundation
import CoreLocation

public protocol WeatherRepository {
    func getWeather(cacheHandler: ([WeatherInformation]) -> Void) async throws -> [WeatherInformation]
    func addFavouriteLocation(coordinates: CLLocationCoordinate2D) async throws -> WeatherInformation
}

// MARK: - Implementation

public final class WeatherRepositoryImpl: WeatherRepository {
    
    private let fetcher: RemoteWeatherFetcher
    private let cache: WeatherCache
    private let currentLocation: () -> CLLocationCoordinate2D
    
    public init(fetcher: RemoteWeatherFetcher, cache: WeatherCache, currentLocation: @escaping () -> CLLocationCoordinate2D) {
        self.fetcher = fetcher
        self.cache = cache
        self.currentLocation = currentLocation
    }
    
    public func getWeather(cacheHandler: ([WeatherInformation]) -> Void) async throws -> [WeatherInformation] {
        let weatherCache = try cache.load()
        cacheHandler(weatherCache)
        
        let currentWeather = try await fetcher.fetch(coordinates: currentLocation(), isCurrentLocation: true)
        var results = [currentWeather]
        for favouriteWeather in weatherCache.filter({ !$0.isCurrentLocation }) {
            let updatedFavouriteWeather = try await fetcher.fetch(coordinates: favouriteWeather.location.coordinates, isCurrentLocation: false)
            results.append(updatedFavouriteWeather)
        }
        
        try cache.save(results)
        
        return results
    }
    
    public func addFavouriteLocation(coordinates: CLLocationCoordinate2D) async throws -> WeatherInformation {
        let weather = try await fetcher.fetch(coordinates: coordinates, isCurrentLocation: false)
        var cached = try cache.load()
        cached.append(weather)
        try cache.save(cached)
        return weather
    }
}
