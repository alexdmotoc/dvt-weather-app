//
//  WeatherInfoViewModelTests.swift
//  WeatherApp-iOSTests
//
//  Created by Alex Motoc on 24.08.2023.
//

import XCTest
import WeatherApp
@testable import WeatherApp_iOS

class WeatherInfoViewModelTests: XCTestCase {
    func test_temperatureValue_returnsCorrectValue() {
        XCTAssertEqual(WeatherInfoViewModel.TemperatureValue.current.title, "Current")
        XCTAssertEqual(WeatherInfoViewModel.TemperatureValue.min.title, "min")
        XCTAssertEqual(WeatherInfoViewModel.TemperatureValue.max.title, "max")
    }
    
    func test_backgroundColorName_returnsCorrectValue() {
        XCTAssertEqual(makeSUT(weatherType: .sunny).backgroundColorName, "sunny")
        XCTAssertEqual(makeSUT(weatherType: .rainy).backgroundColorName, "rainy")
        XCTAssertEqual(makeSUT(weatherType: .cloudy).backgroundColorName, "cloudy")
    }
    
    func test_backgroundImageName_returnsCorrectValue() {
        XCTAssertEqual(makeSUT(weatherType: .sunny).backgroundImageName, "forest_sunny")
        XCTAssertEqual(makeSUT(weatherType: .rainy).backgroundImageName, "forest_rainy")
        XCTAssertEqual(makeSUT(weatherType: .cloudy).backgroundImageName, "forest_cloudy")
    }
    
    func test_weatherTitle_nonEmpty_returnsCorrectValue() {
        XCTAssertEqual(makeSUT(weatherType: .sunny).formattedWeatherTitle, "SUNNY")
        XCTAssertEqual(makeSUT(weatherType: .rainy).formattedWeatherTitle, "RAINY")
        XCTAssertEqual(makeSUT(weatherType: .cloudy).formattedWeatherTitle, "CLOUDY")
    }
    
    func test_weatherTitle_empty_returnsCorrectValue() {
        XCTAssertEqual(makeSUT(isEmpty: true, weatherType: .sunny).formattedWeatherTitle, "--")
        XCTAssertEqual(makeSUT(isEmpty: true, weatherType: .rainy).formattedWeatherTitle, "--")
        XCTAssertEqual(makeSUT(isEmpty: true, weatherType: .cloudy).formattedWeatherTitle, "--")
    }
    
    func test_isEmpty_returnsCorrectValue() {
        XCTAssertEqual(makeSUT(isEmpty: true).isEmpty, true)
        XCTAssertEqual(makeSUT().isEmpty, false)
    }
    
    func test_formatedTemperature_empty_returnsCorrectValue() {
        XCTAssertEqual(makeSUT(isEmpty: true).formattedTemperature(type: .current), "--")
        XCTAssertEqual(makeSUT(isEmpty: true).formattedTemperature(type: .min), "--")
        XCTAssertEqual(makeSUT(isEmpty: true).formattedTemperature(type: .max), "--")
    }
    
    func test_formatedTemperature_nonEmpty_returnsCorrectValue() {
        let sut = makeSUT()
        XCTAssertEqual(sut.formattedTemperature(type: .current), "\(convertTemperature(sut.info.temperature.current, to: sut.temperatureType.unitTemperature))º")
        XCTAssertEqual(sut.formattedTemperature(type: .min), "\(convertTemperature(sut.info.temperature.min, to: sut.temperatureType.unitTemperature))º")
        XCTAssertEqual(sut.formattedTemperature(type: .max), "\(convertTemperature(sut.info.temperature.max, to: sut.temperatureType.unitTemperature))º")
    }
    
    func test_forecast_returnsCorrectValues() {
        let sut = makeSUT()
        XCTAssertEqual(sut.forecast.count, 5)
        
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEEE")
        
        for (index, forecast) in sut.forecast.enumerated() {
            let date = Calendar.current.date(byAdding: .day, value: index + 1, to: Date()) ?? Date()
            XCTAssertEqual(forecast.day, formatter.string(from: date))
            XCTAssertEqual(forecast.temperature, "\(convertTemperature(forecast.forecast.currentTemp, to: forecast.temperatureType.unitTemperature))º")
            switch forecast.forecast.weatherType {
            case .sunny: XCTAssertEqual(forecast.indicatorIconName, "clear")
            case .cloudy: XCTAssertEqual(forecast.indicatorIconName, "partlysunny")
            case .rainy: XCTAssertEqual(forecast.indicatorIconName, "rain")
            }
        }
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(
        isEmpty: Bool = false,
        weatherType: WeatherInformation.WeatherType = .sunny,
        temperatureType: TemperatureType = .celsius
    ) -> WeatherInfoViewModel {
        let viewModel = WeatherInfoViewModel(
            info: isEmpty ? .emptyWeather : .makeMock(name: "Mock", isCurrentLocation: false, weatherType: weatherType),
            temperatureType: temperatureType,
            lastUpdated: "mock last updated",
            onRefresh: {}
        )
        return viewModel
    }
}
