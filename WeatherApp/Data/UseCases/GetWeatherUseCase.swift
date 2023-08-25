//
//  GetWeatherUseCase.swift
//  WeatherApp
//
//  Created by Alex Motoc on 23.08.2023.
//

import Foundation

public protocol GetWeatherUseCase {
    func getWeather(
        currentLocation: Coordinates?,
        cacheHandler: ([WeatherInformation]) -> Void
    ) async throws -> [WeatherInformation]
}

// MARK: - Implementation

public final class GetWeatherUseCaseImpl: GetWeatherUseCase {
    
    private let fetcher: RemoteWeatherFetcher
    private let cache: WeatherCache
    
    public init(fetcher: RemoteWeatherFetcher, cache: WeatherCache) {
        self.fetcher = fetcher
        self.cache = cache
    }
    
    public func getWeather(
        currentLocation: Coordinates?,
        cacheHandler: ([WeatherInformation]) -> Void
    ) async throws -> [WeatherInformation] {
        
        let weatherCache = try cache.load()
        cacheHandler(weatherCache)
        
        let results = try await withThrowingTaskGroup(of: WeatherInformation.self) { [weak self] group in
            guard let self else { return [] as [WeatherInformation] }
            if let currentLocation {
                group.addTask { try await self.fetcher.fetch(coordinates: currentLocation, isCurrentLocation: true) }
            }
            for favouriteWeather in weatherCache.filter({ !$0.isCurrentLocation }) {
                group.addTask {
                    try await self.fetcher.fetch(
                        coordinates: favouriteWeather.location.coordinates,
                        isCurrentLocation: false
                    )
                }
            }
            var results: [WeatherInformation] = []
            
            for try await result in group {
                results.append(result)
            }
            
            return results
        }
        
        let finalResults = Self.getSortedResults(weatherCache: weatherCache, results: results)
        
        try cache.save(finalResults)
        
        return finalResults
    }
    
    /// This algorithm is needed to preserve the order after a concurrent fetch.
    /// - Parameters:
    ///   - weatherCache: the local items in their original order
    ///   - results: the fetched items in a scrambled order
    /// - Returns: the fetched items in the original order
    /// 
    static func getSortedResults(
        weatherCache: [WeatherInformation],
        results: [WeatherInformation]
    ) -> [WeatherInformation] {
        
        var favourites = weatherCache.filter { !$0.isCurrentLocation }
        for index in 0 ..< favourites.count {
            favourites[index].sortOrder = index
        }
        
        let currLocation = results.first(where: { $0.isCurrentLocation })
        var faveResults = results.filter { !$0.isCurrentLocation }
        
        for index in 0 ..< faveResults.count {
            guard let match = favourites.first(
                where: { $0.location.coordinates == faveResults[index].location.coordinates }
            ) else { continue }
            faveResults[index].sortOrder = match.sortOrder
        }
        
        var finalResults: [WeatherInformation] = []
        if let currLocation { finalResults.append(currLocation) }
        finalResults += faveResults.sorted { $0.sortOrder < $1.sortOrder }
        
        return finalResults
    }
}
