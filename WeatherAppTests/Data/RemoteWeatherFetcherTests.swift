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
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func fetch(coordinates: CLLocationCoordinate2D) async throws -> WeatherInformation {
        WeatherInformation.makeMock()
    }
}

final class RemoteWeatherFetcherTests: XCTestCase {
    
    func test_init_doesntInvokeFetch() {
        let client = HTTPClientSpy()
        let sut = RemoteWeatherFetcherImpl(client: client)
        XCTAssertEqual(client.loadCalledCount, 0)
    }
    
    // MARK: - Helpers
    
    private class HTTPClientSpy: HTTPClient {
        var loadCalledCount = 0
        
        func load(urlReqeust: URLRequest) async throws -> (Data, HTTPURLResponse) {
            loadCalledCount += 1
            throw NSError()
        }
    }
}
