//
//  WeatherAPIURLRequestFactoryTests.swift
//  WeatherAppTests
//
//  Created by Alex Motoc on 19.08.2023.
//

import XCTest
import WeatherApp

class WeatherAPIURLRequestFactoryTests: XCTestCase {
    
    func test_weatherEndpoint_generatedCorrectly() throws {
        let request = try WeatherAPIURLRequestFactory.makeURLRequest(
            path: "/weather",
            coordinates: .init(latitude: 1, longitude: 1),
            appId: "mockAppId"
        )
        
        XCTAssertEqual(request.url?.absoluteString, "https://api.openweathermap.org/data/2.5/weather?appid=mockAppId&lat=1.00000&lon=1.00000")
    }
    
    func test_forecastEndpoint_generatedCorrectly() throws {
        let request = try WeatherAPIURLRequestFactory.makeURLRequest(
            path: "/forecast",
            coordinates: .init(latitude: 1, longitude: 1),
            appId: "mockAppId"
        )
        
        XCTAssertEqual(request.url?.absoluteString, "https://api.openweathermap.org/data/2.5/forecast?appid=mockAppId&lat=1.00000&lon=1.00000")
    }
}
