//
//  PlacesAPIEndToEndTests.swift
//  WeatherAppEndToEndTests
//
//  Created by Alex Motoc on 28.08.2023.
//

import XCTest
import WeatherApp

class PlacesAPIEndToEndTests: XCTestCase {
    func test_placesAPI_returnsCorrectData() async throws {
        let details = try await makeSUT().fetchDetails(placeName: "Cluj-Napoca")
        
        XCTAssertFalse(details.photoRefs.isEmpty)
    }
    
    // MARK: - Helpers
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> RemotePlaceDetailsFetcher {
        let client = URLSessionHTTPClient()
        let fetcher = RemotePlaceDetailsFetcherImpl(client: client)
        checkIsDeallocated(sut: client, file: file, line: line)
        checkIsDeallocated(sut: fetcher, file: file, line: line)
        return fetcher
    }
}
