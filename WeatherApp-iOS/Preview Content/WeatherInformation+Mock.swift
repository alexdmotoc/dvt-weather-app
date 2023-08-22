//
//  WeatherInformation+Mock.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 22.08.2023.
//

import WeatherApp

extension WeatherInformation {
    static func makeMock(name: String, isCurrentLocation: Bool, weatherType: WeatherInformation.WeatherType) -> WeatherInformation {
        WeatherInformation(
            isCurrentLocation: isCurrentLocation,
            location: Location(name: name, coordinates: Coordinates(latitude: 19, longitude: 29)),
            temperature: Temperature(current: 200, min: 180, max: 220),
            weatherType: weatherType,
            forecast: (0 ..< 5).map { _ in WeatherInformation.Forecast.makeMock() }
        )
    }
}

extension WeatherInformation.Forecast {
    static func makeMock() -> WeatherInformation.Forecast {
        .init(
            currentTemp: Double.random(in: 150 ... 250),
            weatherType: .init(rawValue: Int.random(in: 0 ... 2)) ?? .sunny
        )
    }
}
