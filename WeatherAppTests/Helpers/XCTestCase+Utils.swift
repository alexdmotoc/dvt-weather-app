//
//  XCTestCase+Utils.swift
//  EssentialFeedTests
//
//  Created by Alex Motoc on 19.08.2023.
//

import XCTest
import WeatherApp

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
        forecast: [WeatherInformation.Forecast] = []
    ) -> WeatherInformation {
        .init(
            isCurrentLocation: isCurrentLocation,
            location: .init(
                name: locationName,
                coordinates: .init(latitude: 10, longitude: 10)
            ),
            temperature: .init(current: 123, min: 100, max: 200),
            weatherType: .sunny,
            forecast: forecast
        )
    }
    
    func makeIndividualForecast() -> WeatherInformation.Forecast {
        .init(currentTemp: 123, weatherType: .init(rawValue: Int.random(in: 0 ... 2)) ?? .sunny)
    }
    
    func makeWeatherInformationWithForecast(name: String = "mock", isCurrentLocation: Bool = false) -> WeatherInformation {
        let forecast = (0 ..< 5).map { _ in makeIndividualForecast() }
        return makeWeatherInformation(locationName: name, isCurrentLocation: isCurrentLocation, forecast: forecast)
    }
    
    func makeWeatherInformationArray(name: String = "mock") -> [WeatherInformation] {
        (0 ..< 5).map { index in makeWeatherInformationWithForecast(name: name, isCurrentLocation: index == 0) }
    }
}
