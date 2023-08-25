//
//  FavouriteLocationUseCase.swift
//  WeatherApp
//
//  Created by Alex Motoc on 23.08.2023.
//

import Foundation

public protocol FavouriteLocationUseCase {
    func addFavouriteLocation(coordinates: Coordinates) async throws -> WeatherInformation
    func removeFavouriteLocation(_ location: WeatherInformation) throws
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
        guard !cached.map(\.location.name).contains(weather.location.name) else {
            throw Error.itemAlreadyExists
        }
        guard !cached.map(\.location.coordinates).contains(weather.location.coordinates) else {
            throw Error.itemAlreadyExists
        }
        cached.append(weather)
        try cache.save(cached)
        return weather
    }
    
    public func removeFavouriteLocation(_ location: WeatherInformation) throws {
        let cached = try cache.load()
        var result = cached.filter { $0.isCurrentLocation }
        var favourites = cached.filter { !$0.isCurrentLocation }
        favourites.removeAll { $0 == location }
        result += favourites
        if result == cached { throw Error.itemNonExistent }
        try cache.save(result)
    }
}

// MARK: - Error

private extension FavouriteLocationUseCaseImpl {
    
    enum Error: Swift.Error, LocalizedError {
        case itemAlreadyExists
        case itemNonExistent
        
        var errorDescription: String? {
            switch self {
            case .itemAlreadyExists:
                return NSLocalizedString("locationAlreadyExists.error.message", bundle: Bundle(for: FavouriteLocationUseCaseImpl.self), comment: "")
            case .itemNonExistent:
                return NSLocalizedString("locationNonExistent.error.message", bundle: Bundle(for: FavouriteLocationUseCaseImpl.self), comment: "")
            }
        }
    }
}
