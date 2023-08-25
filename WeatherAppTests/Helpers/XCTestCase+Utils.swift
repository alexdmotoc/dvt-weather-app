//
//  XCTestCase+Utils.swift
//  EssentialFeedTests
//
//  Created by Alex Motoc on 19.08.2023.
//

import XCTest
@testable import WeatherApp
import CoreLocation

extension XCTestCase {
    func checkIsDeallocated(
        sut: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak sut] in
            XCTAssertNil(sut, file: file, line: line)
        }
    }
    
    func makeNSError() -> NSError {
        NSError(domain: "mock", code: 0)
    }
    
    func makeWeatherInformation(
        locationName: String = "mock",
        isCurrentLocation: Bool = false,
        isRandomCoordinates: Bool = true,
        coordinates: Coordinates? = nil,
        forecast: [WeatherInformation.Forecast] = [],
        sortOrder: Int = 0
    ) -> WeatherInformation {
        var weather = WeatherInformation(
            isCurrentLocation: isCurrentLocation,
            location: .init(
                name: locationName,
                coordinates: coordinates ?? (isRandomCoordinates ? .init(latitude: Double.random(in: -100 ... 100), longitude: Double.random(in: -100 ... 100)) : .init(latitude: 10, longitude: 10))
            ),
            temperature: .init(current: 123, min: 100, max: 200),
            weatherType: .sunny,
            forecast: forecast
        )
        weather.sortOrder = sortOrder
        return weather
    }
    
    func makeIndividualForecast() -> WeatherInformation.Forecast {
        .init(currentTemp: 123, weatherType: .init(rawValue: Int.random(in: 0 ... 2)) ?? .sunny)
    }
    
    func makeWeatherInformationWithForecast(name: String = "mock", isRandomCoordinates: Bool = true, isCurrentLocation: Bool = false) -> WeatherInformation {
        let forecast = (0 ..< 5).map { _ in makeIndividualForecast() }
        return makeWeatherInformation(locationName: name, isCurrentLocation: isCurrentLocation, isRandomCoordinates: isRandomCoordinates, forecast: forecast)
    }
    
    func makeWeatherInformationArray(name: String = "mock") -> [WeatherInformation] {
        (0 ..< 5).map { index in makeWeatherInformationWithForecast(name: name, isCurrentLocation: index == 0) }
    }
    
    static func makeLocation() -> Coordinates {
        .init(latitude: 10, longitude: 10)
    }
    
    func makeLocation(timeStamp: Date = .init()) -> CLLocation {
        .init(
            coordinate: Self.makeLocation().toCLCoordinates,
            altitude: 100,
            horizontalAccuracy: 10,
            verticalAccuracy: 10,
            timestamp: timeStamp
        )
    }
}
