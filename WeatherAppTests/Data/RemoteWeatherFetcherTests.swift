//
//  RemoteWeatherFetcherTests.swift
//  WeatherAppTests
//
//  Created by Alex Motoc on 19.08.2023.
//

import XCTest
import WeatherApp
import CoreLocation

final class RemoteWeatherFetcherTests: XCTestCase {
    
    func test_init_doesntInvokeFetch() {
        let (client, _) = makeSUT()
        XCTAssertEqual(client.loadCalledCount, 0)
    }
    
    func test_fetch_invokesClientTwice() async throws {
        let (client, sut) = makeSUT()
        
        _ = try await sut.fetch(coordinates: makeCoordinates())
        
        XCTAssertEqual(client.loadCalledCount, 2)
    }
    
    func test_fetchTwice_invokesClient4Times() async throws {
        let (client, sut) = makeSUT()
        
        _ = try await sut.fetch(coordinates: makeCoordinates())
        _ = try await sut.fetch(coordinates: makeCoordinates())
        
        XCTAssertEqual(client.loadCalledCount, 4)
    }
    
    func test_onClientError_deliversError() async throws {
        let mockError = makeNSError()
        let (_, sut) = makeSUT(clientError: mockError)
        
        try await expect(sut, toCompleteWith: mockError)
    }
    
    func test_fetch_onNon200StatusCodeReturnsInvalidDataError() async throws {
        let (client, sut) = makeSUT()
        
        for statusCode in [199, 201, 300, 400, 500] {
            client.statusCode = statusCode
            try await expect(sut, toCompleteWith: RemoteWeatherFetcherImpl.Error.invalidData)
        }
    }
    
    func test_fetch_on200StatusCodeWithInvalidDataReturnsInvalidDataError() async throws {
        let (_, sut) = makeSUT(clientStatusCode: 200, clientData: Data("invalid data".utf8))
        
        try await expect(sut, toCompleteWith: RemoteWeatherFetcherImpl.Error.invalidData)
    }
    
    func test_fetch_on200StatusCodeWithValidDataAndEmptyForecastReturnsWeatherInformation() async throws {
        let weatherInfo = makeWeatherInformation()
        let (_, sut) = makeSUT(
            clientStatusCode: 200,
            clientData: makeWeatherJSONData(from: weatherInfo),
            clientForecastData: makeForecastJSONData(from: [])
        )
        
        let result = try await sut.fetch(coordinates: makeCoordinates())
        
        XCTAssertEqual(result, weatherInfo)
    }
    
    func test_fetch_on200StatusCodeWithvalidDataAndNonEmptyForecastReturnsWeatherInformation() async throws {
        let forecast = makeForecast()
        let weatherInfo = makeWeatherInformation(forecast: forecast)
        let (_, sut) = makeSUT(
            clientStatusCode: 200,
            clientData: makeWeatherJSONData(from: weatherInfo),
            clientForecastData: makeForecastJSONData(from: forecast)
        )
        
        let result = try await sut.fetch(coordinates: makeCoordinates())
        
        XCTAssertEqual(result, weatherInfo)
    }
    
    // MARK: - Helpers
    
    private func expect(
        _ sut: RemoteWeatherFetcherImpl,
        toCompleteWith expectedError: Error,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws {
        var didThrow = false
        
        do {
            _ = try await sut.fetch(coordinates: makeCoordinates())
        } catch {
            switch (error, expectedError) {
            case let (error as RemoteWeatherFetcherImpl.Error, expectedError as RemoteWeatherFetcherImpl.Error):
                XCTAssertEqual(error, expectedError, file: file, line: line)
            case let (error as NSError, expectedError as NSError):
                XCTAssertEqual(error, expectedError, file: file, line: line)
            }
            didThrow = true
        }
        
        XCTAssertTrue(didThrow)
    }
    
    private func makeCoordinates() -> CLLocationCoordinate2D {
        .init(latitude: 12, longitude: 12)
    }
    
    private func makeWeatherInformation(
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
    
    private func makeWeatherJSONData(from information: WeatherInformation) -> Data {
        try! JSONSerialization.data(withJSONObject: [
            "coord": [
                "lat": information.location.coordinates.latitude,
                "lon": information.location.coordinates.longitude
            ],
            "weather": [ ["id": information.weatherType.weatherId] ],
            "main": [
                "temp": information.temperature.current,
                "temp_min": information.temperature.min,
                "temp_max": information.temperature.max
            ],
            "name": information.location.name
        ] as [String: Any])
    }
    
    private func makeForecast() -> [WeatherInformation.Forecast] {
        [
            .init(currentTemp: 123, weatherType: .sunny),
            .init(currentTemp: 100, weatherType: .rainy),
            .init(currentTemp: 101, weatherType: .cloudy)
        ]
    }
    
    private func makeForecastJSONData(from forecast: [WeatherInformation.Forecast]) -> Data {
        let list = forecast.map {
            [
                "main": [
                    "temp": $0.currentTemp
                ],
                "weather": [ ["id": $0.weatherType.weatherId] ]
            ] as [String: Any]
        }
        return try! JSONSerialization.data(withJSONObject: [
            "list": list
        ])
    }
    
    private func makeSUT(
        clientError: Error? = nil,
        clientStatusCode: Int? = nil,
        clientData: Data? = nil,
        clientForecastData: Data? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (client: HTTPClientSpy, sut: RemoteWeatherFetcherImpl) {
        
        let client = HTTPClientSpy()
        client.error = clientError
        client.statusCode = clientStatusCode
        client.expectedData = clientData ?? makeWeatherJSONData(from: makeWeatherInformation())
        client.expectedForecastData = clientForecastData ?? makeForecastJSONData(from: makeForecast())
        
        let sut = RemoteWeatherFetcherImpl(client: client)
        
        checkIsDeallocated(sut: client, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        
        return (client, sut)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var loadCalledCount = 0
        var error: Error?
        var statusCode: Int?
        var expectedData: Data?
        var expectedForecastData: Data?
        
        func load(urlReqeust: URLRequest) async throws -> (Data, HTTPURLResponse) {
            loadCalledCount += 1
            if let error { throw error }
            
            let response: HTTPURLResponse
            if let statusCode {
                response = .init(url: urlReqeust.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            } else {
                response = HTTPURLResponse()
            }
            
            let data: Data
            if let expectedData, urlReqeust.url!.absoluteString.contains("/weather") {
                data = expectedData
            } else if let expectedForecastData, urlReqeust.url!.absoluteString.contains("/forecast") {
                data = expectedForecastData
            } else {
                data = Data()
            }
            
            return (data, response)
        }
    }
}

private extension WeatherInformation.WeatherType {
    var weatherId: Int {
        switch self {
        case .sunny: return 800
        case .cloudy: return 801
        case .rainy: return 500
        }
    }
}
