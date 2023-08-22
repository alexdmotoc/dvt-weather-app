//
//  WeatherAPIURLRequestBuilder.swift
//  WeatherApp
//
//  Created by Alex Motoc on 19.08.2023.
//

import Foundation

public struct WeatherAPIURLRequestBuilder {
    private var path: String
    private var coordinates: Coordinates
    private let appId: String
    private let baseURL: String
    
    public init(
        path: String = "",
        coordinates: Coordinates = .init(latitude: 0, longitude: 0),
        appId: String = "e7550ddf86286a184072ad3828a1de20",
        baseURL: String = "https://api.openweathermap.org/data/2.5"
    ) {
        self.path = path
        self.coordinates = coordinates
        self.appId = appId
        self.baseURL = baseURL
    }
    
    public func path(_ path: String) -> Self {
        var builder = self
        builder.path = path
        return builder
    }
    
    public func coordinates(_ coord: Coordinates) -> Self {
        var builder = self
        builder.coordinates = coord
        return builder
    }
    
    public func build() throws -> URLRequest {
        guard var baseURL = URL(string: baseURL) else {
            throw Error.invalidBaseURL
        }
        var queryItems: [URLQueryItem] = []
        queryItems.append(.init(name: "lat", value: String(format: "%.5f", coordinates.latitude)))
        queryItems.append(.init(name: "lon", value: String(format: "%.5f", coordinates.longitude)))
        queryItems.append(.init(name: "appid", value: appId))
        baseURL.append(path: path)
        baseURL.append(queryItems: queryItems)
        return URLRequest(url: baseURL)
    }
    
    private enum Error: Swift.Error {
        case invalidBaseURL
    }
}
