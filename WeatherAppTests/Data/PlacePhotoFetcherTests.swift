//
//  PlacePhotoFetcherTests.swift
//  WeatherAppTests
//
//  Created by Alex Motoc on 29.08.2023.
//

import XCTest
import WeatherApp

final class PlacePhotoFetcherImpl: PlacePhotoFetcher {
    
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func fetchPhoto(reference: String, maxWidth: Int?, maxHeight: Int?) async throws -> Data {
        let request = try PlacesAPIURLRequestFactory.makeGetPhotoURLRequest(
            photoReference: reference,
            maxWidth: maxWidth,
            maxHeight: maxHeight
        )
        let (data, response) = try await client.load(urlReqeust: request)
        return data
    }
}

class PlacePhotoFetcherTests: XCTestCase {
    func test_init_doesntProduceSideEffects() {
        let (client, _) = makeSUT()
        XCTAssertEqual(client.loadCalledCount, 0)
    }
    
    func test_fetchOnce_callsClientOnce() async throws {
        let (client, sut) = makeSUT()
        
        _ = try await sut.fetchPhoto(reference: photoReference, maxWidth: nil, maxHeight: nil)
        
        XCTAssertEqual(client.loadCalledCount, 1)
    }
    
    func test_fetchTwice_callsClientTwice() async throws {
        let (client, sut) = makeSUT()
        
        _ = try await sut.fetchPhoto(reference: photoReference, maxWidth: nil, maxHeight: nil)
        _ = try await sut.fetchPhoto(reference: photoReference, maxWidth: nil, maxHeight: nil)
        
        XCTAssertEqual(client.loadCalledCount, 2)
    }
    
    // MARK: - Helpers
    
    private let photoReference = "mock"
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (client: HTTPClientSpy, sut: PlacePhotoFetcher) {
        let client = HTTPClientSpy()
        let sut = PlacePhotoFetcherImpl(client: client)
        checkIsDeallocated(sut: client, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (client, sut)
    }
}
