//
//  WeatherInformation+Mock.swift
//  WeatherAppTests
//
//  Created by Alex Motoc on 19.08.2023.
//

import Foundation
import WeatherApp

extension WeatherInformation {
    static func makeMock(locationName: String = "Mock") -> WeatherInformation {
        WeatherInformation(
            location: .init(
                name: locationName,
                coordinates: .init(latitude: 42, longitude: 12)
            ),
            temperature: .init(current: 123, min: 100, max: 200),
            weatherType: .sunny,
            forecast: []
        )
    }
}
