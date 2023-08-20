//
//  WeatherInformationTests.swift
//  WeatherAppTests
//
//  Created by Alex Motoc on 20.08.2023.
//

import XCTest
import WeatherApp

class WeatherInformationTests: XCTestCase {
    
    func test_weatherType_computedCorrectly() {
        for id in 0 ..< 799 {
            XCTAssertEqual(WeatherInformation.WeatherType(weatherId: id), .rainy)
        }
        
        XCTAssertEqual(WeatherInformation.WeatherType(weatherId: 800), .sunny)
        
        for id in 801 ..< 1000 {
            XCTAssertEqual(WeatherInformation.WeatherType(weatherId: id), .cloudy)
        }
    }
}
