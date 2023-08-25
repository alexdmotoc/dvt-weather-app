//
//  MapTabViewModelTests.swift
//  WeatherApp-iOSTests
//
//  Created by Alex Motoc on 24.08.2023.
//

import XCTest
import WeatherApp
@testable import WeatherApp_iOS

@MainActor
class MapTabViewModelTests: XCTestCase {
    func test_init_populatesWeatherArrayWithDataFromStore() {
        let items = makeWeatherInformationArray()
        let (_, sut) = makeSUT(mockItems: items)
        
        let receivedItems = sut.weather.map(\.weather)
        XCTAssertEqual(items, receivedItems)
    }
    
    func test_onChange_isNotifiedAndUpdatesWeatherArray() {
        let (store, sut) = makeSUT()
        XCTAssertEqual(sut.weather.map(\.weather), [])
        
        let items = makeWeatherInformationArray()
        store.weatherInformation = items
        
        let exp = expectation(description: "wait for notification")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(sut.weather.map(\.weather), items)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
        
        
    }
    
    func test_onAppend_isNotifiedAndUpdatesWeatherArray() {
        let (store, sut) = makeSUT()
        XCTAssertEqual(sut.weather.map(\.weather), [])
        
        let testWeather = makeWeatherInformationWithForecast(name: "testing")
        store.weatherInformation.append(testWeather)
        
        let exp = expectation(description: "wait for notification")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(sut.weather.map(\.weather), [testWeather])
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        mockItems: [WeatherInformation] = [],
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (store: WeatherInformationStore, sut: MapTabViewModel) {
        let store = WeatherInformationStore(weatherInformation: mockItems)
        let sut = MapTabViewModel(store: store)
        checkIsDeallocated(sut: store, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (store, sut)
    }
}
