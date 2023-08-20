//
//  RemoteWeatherFetcher.swift
//  WeatherApp
//
//  Created by Alex Motoc on 19.08.2023.
//

import Foundation
import CoreLocation

public protocol RemoteWeatherFetcher {
    func fetch(coordinates: CLLocationCoordinate2D) async throws -> WeatherInformation
}

// MARK: - Implementation

public final class RemoteWeatherFetcherImpl: RemoteWeatherFetcher {
    private let client: HTTPClient
    private let builder: WeatherAPIURLRequestBuilder
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public init(client: HTTPClient, builder: WeatherAPIURLRequestBuilder = .init()) {
        self.client = client
        self.builder = builder
    }
    
    public func fetch(coordinates: CLLocationCoordinate2D) async throws -> WeatherInformation {
        let currentWeather = try await fetchCurrentWeather(coordinates: coordinates)
        let forecast = try await fetchForecastWeather(coordinates: coordinates)
        return currentWeather.weatherInformation(with: forecast.forecast)
    }
    
    func fetchCurrentWeather(coordinates: CLLocationCoordinate2D) async throws -> CurrentWeatherAPIDTO {
        let request = try builder.path("/weather").coordinates(coordinates).build()
        let (data, response) = try await client.load(urlReqeust: request)
        guard response.statusCode == 200 else { throw Error.invalidData }
        guard let currentWeather = try? JSONDecoder().decode(CurrentWeatherAPIDTO.self, from: data) else {
            throw Error.invalidData
        }
        return currentWeather
    }
    
    func fetchForecastWeather(coordinates: CLLocationCoordinate2D) async throws -> ForecastWeatherAPIDTO {
        let request = try builder.path("/forecast").coordinates(coordinates).build()
        let (data, response) = try await client.load(urlReqeust: request)
        guard response.statusCode == 200 else { throw Error.invalidData }
        guard let forecast = try? JSONDecoder().decode(ForecastWeatherAPIDTO.self, from: data) else {
            throw Error.invalidData
        }
        return forecast
    }
}
