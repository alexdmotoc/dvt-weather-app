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
        let request = try builder.path("/weather").coordinates(coordinates).build()
        let (_, response) = try await client.load(urlReqeust: request)
        guard response.statusCode == 200 else { throw Error.invalidData }
        return WeatherInformation.makeMock()
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
    
    // MARK: - Helpers
    
    private func expect(_ sut: RemoteWeatherFetcherImpl, toCompleteWith expectedError: Error) async throws {
        var didThrow = false
        
        do {
            _ = try await sut.fetch(coordinates: makeCoordinates())
        } catch {
            switch (error, expectedError) {
            case let (error as RemoteWeatherFetcherImpl.Error, expectedError as RemoteWeatherFetcherImpl.Error):
                XCTAssertEqual(error, expectedError)
            case let (error as NSError, expectedError as NSError):
                XCTAssertEqual(error, expectedError)
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
    
    private func makeSUT(
        clientError: Error? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (client: HTTPClientSpy, sut: RemoteWeatherFetcherImpl) {
        
        let client = HTTPClientSpy()
        client.error = clientError
        
        let sut = RemoteWeatherFetcherImpl(client: client)
        
        checkIsDeallocated(sut: client, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        
        return (client, sut)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var loadCalledCount = 0
        var error: Error?
        var statusCode: Int?
        
        func load(urlReqeust: URLRequest) async throws -> (Data, HTTPURLResponse) {
            loadCalledCount += 1
            if let error { throw error }
            let response: HTTPURLResponse
            if let statusCode {
                response = .init(url: urlReqeust.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            } else {
                response = HTTPURLResponse()
            }
            return (Data(), response)
        }
    }
}
