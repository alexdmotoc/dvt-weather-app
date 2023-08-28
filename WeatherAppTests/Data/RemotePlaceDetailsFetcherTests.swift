//
//  RemotePlaceDetailsFetcherTests.swift
//  WeatherAppTests
//
//  Created by Alex Motoc on 28.08.2023.
//

import XCTest
import WeatherApp

class RemotePlaceDetailsFetcherImpl: RemotePlaceDetailsFetcher {
    
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func fetchDetails(placeName: String) async throws -> PlaceDetails {
        let getPlaceRequest = try PlacesAPIURLRequestFactory.makeGetPlaceURLRequest(query: placeName)
        let (_, _) = try await client.load(urlReqeust: getPlaceRequest)
        return PlaceDetails(photoRefs: [])
    }
}

class RemotePlaceDetailsFetcherTests: XCTestCase {
    func test_init_doesntHaveSideEffects() {
        let (client, _) = makeSUT()
        XCTAssertEqual(client.loadCalledCount, 0)
    }
    
    func test_fetchDetailsOnce_callsClientOnce() async throws {
        let (client, sut) = makeSUT()
        
        _ = try await sut.fetchDetails(placeName: "mock")
        
        XCTAssertEqual(client.loadCalledCount, 1)
    }
    
    func test_fetchDetailsTwice_callsClientTwice() async throws {
        let (client, sut) = makeSUT()
        
        _ = try await sut.fetchDetails(placeName: "mock")
        _ = try await sut.fetchDetails(placeName: "mock")
        
        XCTAssertEqual(client.loadCalledCount, 2)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (client: HTTPClientSpy, sut: RemotePlaceDetailsFetcher) {
        let client = HTTPClientSpy()
        let sut = RemotePlaceDetailsFetcherImpl(client: client)
        checkIsDeallocated(sut: client, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (client, sut)
    }
}
