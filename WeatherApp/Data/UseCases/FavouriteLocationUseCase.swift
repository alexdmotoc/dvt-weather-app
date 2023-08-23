//
//  FavouriteLocationUseCase.swift
//  WeatherApp
//
//  Created by Alex Motoc on 23.08.2023.
//

import Foundation

public protocol FavouriteLocationUseCase {
    func addFavouriteLocation(coordinates: Coordinates) async throws -> WeatherInformation
}

// MARK: - Implementation

public final class FavouriteLocationUseCaseImpl: FavouriteLocationUseCase {
    
    private let fetcher: RemoteWeatherFetcher
    private let cache: WeatherCache
    
    public init(fetcher: RemoteWeatherFetcher, cache: WeatherCache) {
        self.fetcher = fetcher
        self.cache = cache
    }
    
    public func addFavouriteLocation(coordinates: Coordinates) async throws -> WeatherInformation {
        let weather = try await fetcher.fetch(coordinates: coordinates, isCurrentLocation: false)
        var cached = try cache.load()
        cached.append(weather)
        try cache.save(cached)
        return weather
    }
}
