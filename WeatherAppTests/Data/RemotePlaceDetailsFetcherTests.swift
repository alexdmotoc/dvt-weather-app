//
//  RemotePlaceDetailsFetcherTests.swift
//  WeatherAppTests
//
//  Created by Alex Motoc on 28.08.2023.
//

import XCTest
import WeatherApp

class RemotePlaceDetailsFetcherTests: XCTestCase {
    func test_init_doesntHaveSideEffects() {
        let (client, _) = makeSUT()
        XCTAssertEqual(client.loadCalledCount, 0)
    }
    
    func test_fetchDetailsOnce_callsClientTwice() async throws {
        let (client, sut) = makeSUT()
        
        _ = try await sut.fetchDetails(placeName: placeName)
        
        XCTAssertEqual(client.loadCalledCount, 2)
    }
    
    func test_fetchDetailsTwice_callsClient4Times() async throws {
        let (client, sut) = makeSUT()
        
        _ = try await sut.fetchDetails(placeName: placeName)
        _ = try await sut.fetchDetails(placeName: placeName)
        
        XCTAssertEqual(client.loadCalledCount, 4)
    }
    
    func test_onClientError_deliversClientError() async throws {
        let (client, sut) = makeSUT()
        let error = makeNSError()
        client.stubs[makeGetPlaceRequest()] = .init(data: nil, response: nil, error: error)
        
        await expect(sut, toCompleteWith: error)
    }
    
    func test_fecthDetails_onNon200StatusCodeReturnsError() async throws {
        let (client, sut) = makeSUT()
        
        for code in [199, 201, 300, 400, 500] {
            client.stubs[makeGetPlaceRequest()] = .init(data: Data(), response: makeResponse(statusCode: code), error: nil)
            await expect(sut, toCompleteWith: RemotePlaceDetailsFetcherImpl.Error.invalidData)
        }
    }
    
    func test_fecthDetails_on200StatusCodeWithInvalidDataReturnsError() async throws {
        let (client, sut) = makeSUT()
        
        client.stubs[makeGetPlaceRequest()] = .init(data: Data("invalid data".utf8), response: makeResponse(statusCode: 200), error: nil)
        
        await expect(sut, toCompleteWith: RemotePlaceDetailsFetcherImpl.Error.invalidData)
    }
    
    func test_fecthDetails_on200StatusCodeWithValidDataAndNilPlaceIdReturnsPlaceNotFound() async throws {
        let (client, sut) = makeSUT()
        
        client.stubs[makeGetPlaceRequest()] = .init(data: makeNilPlaceData(), response: makeResponse(statusCode: 200), error: nil)
        
        await expect(sut, toCompleteWith: RemotePlaceDetailsFetcherImpl.Error.placeNotFound)
    }
    
    func test_fetchDetails_onValidPlace_onPlaceDetails_returnsClientError() async throws {
        let (client, sut) = makeSUT()
        
        let error = makeNSError()
        client.stubs[makeGetPlaceRequest()] = .init(data: makeValidPlaceData(), response: makeResponse(statusCode: 200), error: nil)
        client.stubs[makeGetPlaceDetailsRequest()] = .init(data: nil, response: nil, error: error)
        
        await expect(sut, toCompleteWith: error)
    }
    
    func test_fetchDetails_onValidPlace_onPlaceDetails_onNon200StatusCodeReturnsError() async throws {
        let (client, sut) = makeSUT()
        
        client.stubs[makeGetPlaceRequest()] = .init(data: makeValidPlaceData(), response: makeResponse(statusCode: 200), error: nil)
        
        for code in [199, 201, 300, 400, 500] {
            client.stubs[makeGetPlaceDetailsRequest()] = .init(data: Data(), response: makeResponse(statusCode: code), error: nil)
            await expect(sut, toCompleteWith: RemotePlaceDetailsFetcherImpl.Error.invalidData)
        }
    }
    
    func test_fetchDetails_onValidPlace_onPlaceDetails_on200StatusCodeWithInvalidDataReturnsError() async throws {
        let (client, sut) = makeSUT()
        
        client.stubs[makeGetPlaceRequest()] = .init(data: makeValidPlaceData(), response: makeResponse(statusCode: 200), error: nil)
        client.stubs[makeGetPlaceDetailsRequest()] = .init(data: Data("invalid data".utf8), response: makeResponse(statusCode: 200), error: nil)
        
        await expect(sut, toCompleteWith: RemotePlaceDetailsFetcherImpl.Error.invalidData)
    }
    
    func test_fetchDetails_onValidPlace_onPlaceDetails_on200StatusCodeWithValidDataReturnsPlaceDetails() async throws {
        let (client, sut) = makeSUT()
        
        client.stubs[makeGetPlaceRequest()] = .init(data: makeValidPlaceData(), response: makeResponse(statusCode: 200), error: nil)
        client.stubs[makeGetPlaceDetailsRequest()] = .init(data: makeValidPlaceDetailsData(), response: makeResponse(statusCode: 200), error: nil)
        
        let expectedResult = makePlaceDetails()
        let result = try await sut.fetchDetails(placeName: placeName)
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func test_fetchDetails_onValidPlace_onPlaceDetails_on200StatusCodeWithNilDataReturnsPlaceDetails() async throws {
        let (client, sut) = makeSUT()
        
        client.stubs[makeGetPlaceRequest()] = .init(data: makeValidPlaceData(), response: makeResponse(statusCode: 200), error: nil)
        client.stubs[makeGetPlaceDetailsRequest()] = .init(data: makeNilPlaceDetailsData(), response: makeResponse(statusCode: 200), error: nil)
        
        let expectedResult = makeEmptyPlaceDetails()
        let result = try await sut.fetchDetails(placeName: placeName)
        
        XCTAssertEqual(result, expectedResult)
    }
    
    // MARK: - Helpers
    
    private let placeName = "mock"
    private let placeId = "mock"
    
    private func makePlaceDetails() -> PlaceDetails {
        .init(photoRefs: [
            .init(reference: "mock1", width: 100, height: 100),
            .init(reference: "mock2", width: 100, height: 100),
            .init(reference: "mock3", width: 100, height: 100)
        ])
    }
    
    private func makeEmptyPlaceDetails() -> PlaceDetails {
        .init(photoRefs: [])
    }
    
    private func makeValidPlaceData() -> Data {
        try! JSONSerialization.data(withJSONObject: [
            "results": [
                ["place_id": placeId]
            ]
        ])
    }
    
    private func makeNilPlaceData() -> Data {
        try! JSONSerialization.data(withJSONObject: [
            "results": [
                ["place_id": nil] as [String: Any?]
            ]
        ])
    }
    
    private func makeValidPlaceDetailsData() -> Data {
        try! JSONSerialization.data(withJSONObject: [
            "result": [
                "photos": [
                    ["width": 100, "height": 100, "photo_reference": "mock1"] as [String: Any],
                    ["width": 100, "height": 100, "photo_reference": "mock2"] as [String: Any],
                    ["width": 100, "height": 100, "photo_reference": "mock3"] as [String: Any]
                ]
            ]
        ])
    }
    
    private func makeNilPlaceDetailsData() -> Data {
        try! JSONSerialization.data(withJSONObject: [
            "result": [
                "photos": nil
            ] as [String: Any?]
        ])
    }
    
    private func expect(
        _ sut: RemotePlaceDetailsFetcher,
        toCompleteWith expectedError: Error,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        var didThrow = false
        
        do {
            _ = try await sut.fetchDetails(placeName: placeName)
        } catch {
            switch (error, expectedError) {
            case let (error as RemotePlaceDetailsFetcherImpl.Error, expectedError as RemotePlaceDetailsFetcherImpl.Error):
                XCTAssertEqual(error, expectedError, file: file, line: line)
                XCTAssertFalse(error.localizedDescription.isEmpty)
            case let (error as NSError, expectedError as NSError):
                XCTAssertEqual(error, expectedError, file: file, line: line)
            }
            didThrow = true
        }
        
        XCTAssertTrue(didThrow, file: file, line: line)
    }
    
    private func makeGetPlaceRequest() -> URLRequest {
        try! PlacesAPIURLRequestFactory.makeGetPlaceURLRequest(query: placeName)
    }
    
    private func makeGetPlaceDetailsRequest() -> URLRequest {
        try! PlacesAPIURLRequestFactory.makeGetPlaceDetailsURLRequest(placeId: placeId)
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (client: HTTPClientSpy, sut: RemotePlaceDetailsFetcher) {
        let client = HTTPClientSpy()
        let sut = RemotePlaceDetailsFetcherImpl(client: client)
        client.stubs[makeGetPlaceRequest()] = .init(data: makeValidPlaceData(), response: makeResponse(statusCode: 200), error: nil)
        client.stubs[makeGetPlaceDetailsRequest()] = .init(data: makeValidPlaceDetailsData(), response: makeResponse(statusCode: 200), error: nil)
        checkIsDeallocated(sut: client, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (client, sut)
    }
}
