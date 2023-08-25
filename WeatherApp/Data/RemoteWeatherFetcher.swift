//
//  RemoteWeatherFetcher.swift
//  WeatherApp
//
//  Created by Alex Motoc on 19.08.2023.
//

import Foundation

public protocol RemoteWeatherFetcher {
    func fetch(coordinates: Coordinates, isCurrentLocation: Bool) async throws -> WeatherInformation
}

// MARK: - Implementation

public final class RemoteWeatherFetcherImpl: RemoteWeatherFetcher {
    private let client: HTTPClient
    private let builder: WeatherAPIURLRequestBuilder
    
    public enum Error: Swift.Error, LocalizedError {
        case invalidData
        
        public var errorDescription: String? {
            switch self {
            case.invalidData:
                return NSLocalizedString(
                    "api.error.message",
                    bundle: Bundle(for: RemoteWeatherFetcherImpl.self),
                    comment: ""
                )
            }
        }
    }
    
    public init(client: HTTPClient, builder: WeatherAPIURLRequestBuilder = .init()) {
        self.client = client
        self.builder = builder
    }
    
    public func fetch(coordinates: Coordinates, isCurrentLocation: Bool) async throws -> WeatherInformation {
        let currentWeather = try await fetchCurrentWeather(coordinates: coordinates)
        let forecast = try await fetchForecastWeather(coordinates: coordinates)
        return currentWeather.weatherInformation(
            with: ForecastReducer.reduceHourlyForecastToDaily(forecast.forecast),
            isCurrentLocation: isCurrentLocation
        )
    }
    
    private func fetchCurrentWeather(coordinates: Coordinates) async throws -> CurrentWeatherAPIDTO {
        let request = try builder.path("/weather").coordinates(coordinates).build()
        let (data, response) = try await client.load(urlReqeust: request)
        return try DataMapper.map(data: data, response: response)
    }
    
    private func fetchForecastWeather(coordinates: Coordinates) async throws -> ForecastWeatherAPIDTO {
        let request = try builder.path("/forecast").coordinates(coordinates).build()
        let (data, response) = try await client.load(urlReqeust: request)
        return try DataMapper.map(data: data, response: response)
    }
}

// MARK: - Helpers

private enum DataMapper {
    static func map<T: Decodable>(data: Data, response: HTTPURLResponse) throws -> T {
        guard
            response.statusCode == 200,
            let mapped = try? JSONDecoder().decode(T.self, from: data)
        else { throw RemoteWeatherFetcherImpl.Error.invalidData }
        return mapped
    }
}
