//
//  WeatherInformation+Mock.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 22.08.2023.
//

import WeatherApp

extension WeatherInformation {
    static func makeMock(
        name: String,
        isCurrentLocation: Bool,
        weatherType: WeatherInformation.WeatherType
    ) -> WeatherInformation {
        WeatherInformation(
            isCurrentLocation: isCurrentLocation,
            location: Location(name: name, coordinates: Coordinates(latitude: 46.770439, longitude: 23.591423)),
            temperature: Temperature(current: 200, min: 180, max: 220),
            weatherType: weatherType,
            forecast: (0 ..< 5).map { _ in WeatherInformation.Forecast.makeMock() }
        )
    }
    
    static var emptyWeather: WeatherInformation {
        WeatherInformation(
            isCurrentLocation: false,
            location: .init(name: "--", coordinates: .init(latitude: 0, longitude: 0)),
            temperature: .init(current: 0, min: 0, max: 0),
            weatherType: .sunny,
            forecast: []
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
