//
//  WeatherAppEndToEndTests.swift
//  WeatherAppEndToEndTests
//
//  Created by Alex Motoc on 20.08.2023.
//

import XCTest
import WeatherApp

final class WeatherAppEndToEndTests: XCTestCase {
    func test_fetchWeatherFromAPI_worksCorrectly() async throws {
        let clujNapocaCoordinates = Coordinates(latitude: 46.770439, longitude: 23.591423)
        
        let weather = try await makeSUT().fetch(coordinates: clujNapocaCoordinates, isCurrentLocation: true)
        
        XCTAssertEqual(weather.location.name, "Cluj-Napoca")
        XCTAssertEqual(weather.forecast.count, 5)
    }
    
    // MARK: - Helpers
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> RemoteWeatherFetcher {
        let client = URLSessionHTTPClient()
        let fetcher = RemoteWeatherFetcherImpl(client: client)
        checkIsDeallocated(sut: client, file: file, line: line)
        checkIsDeallocated(sut: fetcher, file: file, line: line)
        return fetcher
    }
}
