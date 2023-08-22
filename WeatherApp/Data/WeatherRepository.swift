//
//  WeatherRepository.swift
//  WeatherApp
//
//  Created by Alex Motoc on 21.08.2023.
//

import Foundation

public protocol WeatherRepository {
    func getWeather(currentLocation: Coordinates?, cacheHandler: ([WeatherInformation]) -> Void) async throws -> [WeatherInformation]
    func addFavouriteLocation(coordinates: Coordinates) async throws -> WeatherInformation
}

// MARK: - Implementation

public final class WeatherRepositoryImpl: WeatherRepository {
    
    private let fetcher: RemoteWeatherFetcher
    private let cache: WeatherCache
    
    public init(fetcher: RemoteWeatherFetcher, cache: WeatherCache) {
        self.fetcher = fetcher
        self.cache = cache
    }
    
    public func getWeather(currentLocation: Coordinates?, cacheHandler: ([WeatherInformation]) -> Void) async throws -> [WeatherInformation] {
        let weatherCache = try cache.load()
        cacheHandler(weatherCache)
        
        var results: [WeatherInformation] = []
        
        if let currentLocation {
            let currentWeather = try await fetcher.fetch(coordinates: currentLocation, isCurrentLocation: true)
            results.append(currentWeather)
        }
        
        for favouriteWeather in weatherCache.filter({ !$0.isCurrentLocation }) {
            let updatedFavouriteWeather = try await fetcher.fetch(coordinates: favouriteWeather.location.coordinates, isCurrentLocation: false)
            results.append(updatedFavouriteWeather)
        }
        
        try cache.save(results)
        
        return results
    }
    
    public func addFavouriteLocation(coordinates: Coordinates) async throws -> WeatherInformation {
        let weather = try await fetcher.fetch(coordinates: coordinates, isCurrentLocation: false)
        var cached = try cache.load()
        cached.append(weather)
        try cache.save(cached)
        return weather
    }
}
