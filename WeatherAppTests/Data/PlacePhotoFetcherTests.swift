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
    
    func fetchPhoto(reference: String, minWidth: Int?, minHeight: Int?) async throws -> Data {
        Data()
    }
}

class PlacePhotoFetcherTests: XCTestCase {
    func test_init_doesntProduceSideEffects() {
        let (client, _) = makeSUT()
        XCTAssertEqual(client.loadCalledCount, 0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (client: HTTPClientSpy, sut: PlacePhotoFetcher) {
        let client = HTTPClientSpy()
        let sut = PlacePhotoFetcherImpl(client: client)
        checkIsDeallocated(sut: client, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (client, sut)
    }
}
