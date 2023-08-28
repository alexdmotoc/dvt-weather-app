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
        let (data, response) = try await client.load(urlReqeust: getPlaceRequest)
        guard
            response.statusCode == 200,
            let place = try? JSONDecoder().decode(PlaceDTO.self, from: data)
        else { throw Error.invalidData }
        return PlaceDetails(photoRefs: [])
    }
    
    // MARK: - Error
    
    enum Error: Swift.Error {
        case invalidData
    }
}

struct PlaceDTO: Decodable {
    let place_id: String?
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
    
    // MARK: - Helpers
    
    private func makeValidPlaceData() -> Data {
        try! JSONSerialization.data(withJSONObject: [
            "place_id": "mock"
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
            _ = try await sut.fetchDetails(placeName: "mock")
        } catch {
            switch (error, expectedError) {
            case let (error as RemotePlaceDetailsFetcherImpl.Error, expectedError as RemotePlaceDetailsFetcherImpl.Error):
                XCTAssertEqual(error, expectedError, file: file, line: line)
//                XCTAssertEqual(error.localizedDescription, NSLocalizedString("api.error.message", bundle: Bundle(for: RemoteWeatherFetcherImpl.self), comment: ""))
            case let (error as NSError, expectedError as NSError):
                XCTAssertEqual(error, expectedError, file: file, line: line)
            }
            didThrow = true
        }
        
        XCTAssertTrue(didThrow, file: file, line: line)
    }
    
    private func makeGetPlaceRequest() -> URLRequest {
        try! PlacesAPIURLRequestFactory.makeGetPlaceURLRequest(query: "mock")
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (client: HTTPClientSpy, sut: RemotePlaceDetailsFetcher) {
        let client = HTTPClientSpy()
        let sut = RemotePlaceDetailsFetcherImpl(client: client)
        client.stubs[makeGetPlaceRequest()] = .init(data: makeValidPlaceData(), response: makeResponse(statusCode: 200), error: nil)
        checkIsDeallocated(sut: client, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (client, sut)
    }
}
