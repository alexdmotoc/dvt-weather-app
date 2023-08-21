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
        forecast: [WeatherInformation.Forecast] = []
    ) -> WeatherInformation {
        .init(
            location: .init(
                name: locationName,
                coordinates: .init(latitude: 10, longitude: 10)
            ),
            temperature: .init(current: 123, min: 100, max: 200),
            weatherType: .sunny,
            forecast: forecast
        )
    }
}
