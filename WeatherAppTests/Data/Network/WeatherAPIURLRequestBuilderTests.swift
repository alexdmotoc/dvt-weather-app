//
//  WeatherAPIURLRequestBuilderTests.swift
//  WeatherAppTests
//
//  Created by Alex Motoc on 19.08.2023.
//

import XCTest
import WeatherApp

class WeatherAPIURLRequestBuilderTests: XCTestCase {
    
    func test_weatherEndpoint_generatedCorrectly() throws {
        let builder = WeatherAPIURLRequestBuilder(appId: "mockAppId")
        
        let request = try builder.path("/weather").coordinates(.init(latitude: 1, longitude: 1)).build()
        
        XCTAssertEqual(request.url?.absoluteString, "https://api.openweathermap.org/data/2.5/weather?lat=1.00000&lon=1.00000&appid=mockAppId")
    }
    
    func test_forecastEndpoint_generatedCorrectly() throws {
        let builder = WeatherAPIURLRequestBuilder(appId: "mockAppId")
        
        let request = try builder.path("/forecast").coordinates(.init(latitude: 1, longitude: 1)).build()
        
        XCTAssertEqual(request.url?.absoluteString, "https://api.openweathermap.org/data/2.5/forecast?lat=1.00000&lon=1.00000&appid=mockAppId")
    }
    
}
