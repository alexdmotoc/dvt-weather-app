//
//  PlacePhotoFetcherTests.swift
//  WeatherAppTests
//
//  Created by Alex Motoc on 29.08.2023.
//

import XCTest
import WeatherApp

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
    
    func test_onClientError_returnsError() async {
        let (client, sut) = makeSUT()
        let error = makeNSError()
        client.stubs[makeGetPhotoRequest()] = .init(data: nil, response: nil, error: error)
        
        await expect(sut, toCompleteWith: error)
    }
    
    func test_fetch_onNon200StatusCodeReturnsError() async {
        let (client, sut) = makeSUT()
        
        for statusCode in [199, 201, 300, 400, 500] {
            client.stubs[makeGetPhotoRequest()] = .init(data: makeNonEmptyData(), response: makeResponse(statusCode: statusCode), error: nil)
            await expect(sut, toCompleteWith: PlacePhotoFetcherImpl.Error.invalidData)
        }
    }
    
    func test_fetch_on200StatusCodeWithEmptyDataReturnsError() async {
        let (client, sut) = makeSUT()
        
        client.stubs[makeGetPhotoRequest()] = .init(data: makeEmptyData(), response: makeResponse(statusCode: 200), error: nil)
        
        await expect(sut, toCompleteWith: PlacePhotoFetcherImpl.Error.invalidData)
    }
    
    func test_fetch_on200StatusCodeWithNonEmptyDataReturnsData() async throws {
        let (client, sut) = makeSUT()
        let data = makeNonEmptyData()
        
        client.stubs[makeGetPhotoRequest()] = .init(data: data, response: makeResponse(statusCode: 200), error: nil)
        let result = try await sut.fetchPhoto(reference: photoReference, maxWidth: nil, maxHeight: nil)
        
        XCTAssertEqual(result, data)
    }
    
    // MARK: - Helpers
    
    private let photoReference = "mock"
    
    private func makeGetPhotoRequest() -> URLRequest {
        try! PlacesAPIURLRequestFactory.makeGetPhotoURLRequest(photoReference: photoReference)
    }
    
    private func makeNonEmptyData() -> Data {
        Data("non empty".utf8)
    }
    
    private func makeEmptyData() -> Data {
        Data()
    }
    
    private func expect(
        _ sut: PlacePhotoFetcher,
        toCompleteWith expectedError: Error,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        var didThrow = false
        
        do {
            _ = try await sut.fetchPhoto(reference: photoReference, maxWidth: nil, maxHeight: nil)
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
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (client: HTTPClientSpy, sut: PlacePhotoFetcher) {
        let client = HTTPClientSpy()
        let sut = PlacePhotoFetcherImpl(client: client)
        client.stubs[makeGetPhotoRequest()] = .init(data: makeNonEmptyData(), response: makeResponse(statusCode: 200), error: nil)
        checkIsDeallocated(sut: client, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (client, sut)
    }
}
