//
//  RemoteWeatherFetcherTests.swift
//  WeatherAppTests
//
//  Created by Alex Motoc on 19.08.2023.
//

import XCTest
import WeatherApp
import CoreLocation

final class RemoteWeatherFetcherImpl: RemoteWeatherFetcher {
    private let client: HTTPClient
    private let builder: WeatherAPIURLRequestBuilder
    
    enum Error: Swift.Error {
        case invalidData
    }
    
    init(client: HTTPClient, builder: WeatherAPIURLRequestBuilder = .init()) {
        self.client = client
        self.builder = builder
    }
    
    func fetch(coordinates: CLLocationCoordinate2D) async throws -> WeatherInformation {
        let weatherRequest = try builder.path("/weather").coordinates(coordinates).build()
        let (data, response) = try await client.load(urlReqeust: weatherRequest)
        guard response.statusCode == 200 else { throw Error.invalidData }
        guard let currentWeather = try? JSONDecoder().decode(CurrentWeatherAPIDTO.self, from: data) else {
            throw Error.invalidData
        }
        return WeatherInformation.makeMock()
    }
}

struct CurrentWeatherAPIDTO: Codable {
    let coord: Coordinates
    let weather: [Weather]
    let main: Main
    
    struct Coordinates: Codable {
        let lat: Double
        let lon: Double
    }
    
    struct Weather: Codable {
        let id: Int
    }
    
    struct Main: Codable {
        let temp: Double
        let temp_min: Double
        let temp_max: Double
    }
}

final class RemoteWeatherFetcherTests: XCTestCase {
    
    func test_init_doesntInvokeFetch() {
        let (client, _) = makeSUT()
        XCTAssertEqual(client.loadCalledCount, 0)
    }
    
    func test_fetch_invokesClientOnce() async throws {
        let (client, sut) = makeSUT()
        
        _ = try await sut.fetch(coordinates: makeCoordinates())
        
        XCTAssertEqual(client.loadCalledCount, 1)
    }
    
    func test_fetchTwice_invokesClientTwice() async throws {
        let (client, sut) = makeSUT()
        
        _ = try await sut.fetch(coordinates: makeCoordinates())
        _ = try await sut.fetch(coordinates: makeCoordinates())
        
        XCTAssertEqual(client.loadCalledCount, 2)
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
    
    private func makeNSError() -> NSError {
        NSError(domain: "mock", code: 0)
    }
    
    private func makeCoordinates() -> CLLocationCoordinate2D {
        .init(latitude: 12, longitude: 12)
    }
    
    private static func makeValidWeatherData() -> Data {
        let dto = CurrentWeatherAPIDTO(
            coord: .init(lat: 10, lon: 10),
            weather: [.init(id: 123)],
            main: .init(temp: 123, temp_min: 100, temp_max: 200)
        )
        return (try? JSONEncoder().encode(dto)) ?? Data()
    }
    
    private func makeSUT(
        clientError: Error? = nil,
        clientStatusCode: Int? = nil,
        clientData: Data? = makeValidWeatherData(),
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (client: HTTPClientSpy, sut: RemoteWeatherFetcherImpl) {
        
        let client = HTTPClientSpy()
        client.error = clientError
        client.statusCode = clientStatusCode
        client.expectedData = clientData
        
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
            if let expectedData {
                data = expectedData
            } else {
                data = Data()
            }
            
            return (data, response)
        }
    }
}
