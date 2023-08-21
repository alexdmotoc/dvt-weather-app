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
        let (client, sut) = makeSUT()
        
        client.stubs[weatherURLRequest()] = .init(data: nil, response: nil, error: mockError)
        
        try await expect(sut, toCompleteWith: mockError)
    }
    
    func test_fetch_onNon200StatusCodeReturnsInvalidDataError() async throws {
        let (client, sut) = makeSUT()
        
        for statusCode in [199, 201, 300, 400, 500] {
            client.stubs[weatherURLRequest()] = .init(data: nil, response: makeResponse(statusCode: statusCode), error: nil)
            try await expect(sut, toCompleteWith: RemoteWeatherFetcherImpl.Error.invalidData)
        }
    }
    
    func test_fetch_forecast_onNon200StatusCodeReturnsInvalidDataError() async throws {
        let (client, sut) = makeSUT()
        
        for statusCode in [199, 201, 300, 400, 500] {
            client.stubs[forecastURLRequest()] = .init(data: nil, response: makeResponse(statusCode: statusCode), error: nil)
            try await expect(sut, toCompleteWith: RemoteWeatherFetcherImpl.Error.invalidData)
        }
    }
    
    func test_fetch_on200StatusCodeWithInvalidDataReturnsInvalidDataError() async throws {
        let (client, sut) = makeSUT()
        client.stubs[weatherURLRequest()] = .init(data: Data("invalid data".utf8), response: makeResponse(statusCode: 200), error: nil)
        
        try await expect(sut, toCompleteWith: RemoteWeatherFetcherImpl.Error.invalidData)
    }
    
    func test_fetch_forecast_on200StatusCodeWithInvalidDataReturnsInvalidDataError() async throws {
        let (client, sut) = makeSUT()
        client.stubs[forecastURLRequest()] = .init(data: Data("invalid data".utf8), response: makeResponse(statusCode: 200), error: nil)
        
        try await expect(sut, toCompleteWith: RemoteWeatherFetcherImpl.Error.invalidData)
    }
    
    func test_fetch_on200StatusCodeWithValidDataAndEmptyForecastReturnsWeatherInformation() async throws {
        let weatherInfo = makeWeatherInformation()
        let (client, sut) = makeSUT()
        client.stubs[weatherURLRequest()] = .init(data: makeWeatherJSONData(from: weatherInfo), response: makeResponse(statusCode: 200), error: nil)
        client.stubs[forecastURLRequest()] = .init(data: makeForecastJSONData(from: []), response: makeResponse(statusCode: 200), error: nil)
        
        let result = try await sut.fetch(coordinates: makeCoordinates())
        
        XCTAssertEqual(result, weatherInfo)
    }
    
    func test_fetch_on200StatusCodeWithvalidDataAndNonEmptyForecastReturnsWeatherInformation() async throws {
        let forecast = makeForecast()
        let weatherInfo = makeWeatherInformation(forecast: ForecastReducer.reduceHourlyForecastToDaily(forecast))
        let (client, sut) = makeSUT()
        client.stubs[weatherURLRequest()] = .init(data: makeWeatherJSONData(from: weatherInfo), response: makeResponse(statusCode: 200), error: nil)
        client.stubs[forecastURLRequest()] = .init(data: makeForecastJSONData(from: forecast), response: makeResponse(statusCode: 200), error: nil)
        
        let result = try await sut.fetch(coordinates: makeCoordinates())
        
        XCTAssertEqual(result, weatherInfo)
    }
    
    // MARK: - Helpers
    
    private func makeResponse(statusCode: Int) -> HTTPURLResponse {
        .init(url: URL(string: "https://someurl.com")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
    
    private func weatherURLRequest() -> URLRequest {
        try! WeatherAPIURLRequestBuilder().path("/weather").coordinates(makeCoordinates()).build()
    }
    
    private func forecastURLRequest() -> URLRequest {
        try! WeatherAPIURLRequestBuilder().path("/forecast").coordinates(makeCoordinates()).build()
    }
    
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
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (client: HTTPClientSpy, sut: RemoteWeatherFetcherImpl) {
        
        let weatherInfo = makeWeatherInformation()
        let client = HTTPClientSpy()
        client.stubs[weatherURLRequest()] = .init(data: makeWeatherJSONData(from: weatherInfo), response: makeResponse(statusCode: 200), error: nil)
        client.stubs[forecastURLRequest()] = .init(data: makeForecastJSONData(from: []), response: makeResponse(statusCode: 200), error: nil)
        
        let sut = RemoteWeatherFetcherImpl(client: client)
        
        checkIsDeallocated(sut: client, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        
        return (client, sut)
    }
    
    private class HTTPClientSpy: HTTPClient {
        struct Stub {
            let data: Data?
            let response: HTTPURLResponse?
            let error: Error?
        }
        
        var loadCalledCount = 0
        var stubs: [URLRequest: Stub] = [:]
        
        func load(urlReqeust: URLRequest) async throws -> (Data, HTTPURLResponse) {
            loadCalledCount += 1
            
            let stub = stubs[urlReqeust]
            
            if let error = stub?.error {
                throw error
            }
            
            if let data = stub?.data, let response = stub?.response {
                return (data, response)
            }
            
            return (Data(), HTTPURLResponse())
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
