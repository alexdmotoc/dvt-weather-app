//
//  ForecastReducerTests.swift
//  WeatherAppTests
//
//  Created by Alex Motoc on 20.08.2023.
//

import XCTest
import WeatherApp

class ForecastReducerTests: XCTestCase {
    func test_reduces_oneItemToOne() {
        let forecast = makeForecast()
        
        XCTAssertEqual([forecast], ForecastReducer.reduceHourlyForecastToDaily([forecast]))
    }
    
    func test_reduces_eightItemsToOne() {
        let forecast = (0 ..< 8).map { _ in makeForecast() }
        
        XCTAssertEqual([makeForecast()], ForecastReducer.reduceHourlyForecastToDaily(forecast))
    }
    
    func test_reduces_39ItemsTo5() {
        let forecast = (0 ..< 39).map { _ in makeForecast() }
        let expectedResult = (0 ..< 5).map { _ in makeForecast() }
        
        XCTAssertEqual(expectedResult, ForecastReducer.reduceHourlyForecastToDaily(forecast))
    }
    
    func test_reduces_40ItemsTo5() {
        let forecast = (0 ..< 40).map { _ in makeForecast() }
        let expectedResult = (0 ..< 5).map { _ in makeForecast() }
        
        XCTAssertEqual(expectedResult, ForecastReducer.reduceHourlyForecastToDaily(forecast))
    }
    
    func test_reduces_41ItemsTo6() {
        let forecast = (0 ..< 41).map { _ in makeForecast() }
        let expectedResult = (0 ..< 6).map { _ in makeForecast() }
        
        XCTAssertEqual(expectedResult, ForecastReducer.reduceHourlyForecastToDaily(forecast))
    }
    
    // MARK: - Helpers
    
    func makeForecast(temp: Double = 100, weatherType: WeatherInformation.WeatherType = .sunny) -> WeatherInformation.Forecast {
        .init(currentTemp: temp, weatherType: weatherType)
    }
}
