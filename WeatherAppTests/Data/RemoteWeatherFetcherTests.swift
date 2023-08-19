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
    
    init(client: HTTPClient, builder: WeatherAPIURLRequestBuilder = .init()) {
        self.client = client
        self.builder = builder
    }
    
    func fetch(coordinates: CLLocationCoordinate2D) async throws -> WeatherInformation {
        let request = try builder.path("/weather").coordinates(coordinates).build()
        let (_, _) = try await client.load(urlReqeust: request)
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
        
        _ = try await sut.fetch(coordinates: .init(latitude: 12, longitude: 12))
        
        XCTAssertEqual(client.loadCalledCount, 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (client: HTTPClientSpy, sut: RemoteWeatherFetcherImpl) {
        let client = HTTPClientSpy()
        let sut = RemoteWeatherFetcherImpl(client: client)
        
        checkIsDeallocated(sut: client)
        checkIsDeallocated(sut: sut)
        
        return (client, sut)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var loadCalledCount = 0
        
        func load(urlReqeust: URLRequest) async throws -> (Data, HTTPURLResponse) {
            loadCalledCount += 1
            return (Data(), HTTPURLResponse())
        }
    }
}
