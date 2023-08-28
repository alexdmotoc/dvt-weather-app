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
        let response = try await fetchPlace(name: placeName)
        guard let placeId = response.results.first?.place_id else { throw Error.placeNotFound }
        let details = try await fetchPlaceDetails(placeId: placeId)
        return details.toLocal
    }
    
    private func fetchPlace(name: String) async throws -> PlaceResponseDTO {
        let request = try PlacesAPIURLRequestFactory.makeGetPlaceURLRequest(query: name)
        let (data, response) = try await client.load(urlReqeust: request)
        guard
            response.statusCode == 200,
            let place = try? JSONDecoder().decode(PlaceResponseDTO.self, from: data)
        else { throw Error.invalidData }
        return place
    }
    
    private func fetchPlaceDetails(placeId: String) async throws -> PlaceDetailsDTO {
        let request = try PlacesAPIURLRequestFactory.makeGetPlaceDetailsURLRequest(placeId: placeId)
        let (data, response) = try await client.load(urlReqeust: request)
        guard
            response.statusCode == 200,
            let details = try? JSONDecoder().decode(PlaceDetailsDTO.self, from: data)
        else { throw Error.invalidData }
        return details
    }
    
    // MARK: - Error
    
    enum Error: Swift.Error {
        case invalidData
        case placeNotFound
    }
}

struct PlaceResponseDTO: Decodable {
    let results: [Result]
    
    struct Result: Decodable {
        let place_id: String?
    }
}

struct PlaceDetailsDTO: Decodable {
    let result: Result
    
    struct Result: Decodable {
        let photos: [Photo]?
    }
    
    struct Photo: Decodable {
        let height: Int
        let width: Int
        let photo_reference: String
    }
    
    var toLocal: PlaceDetails {
        .init(photoRefs: result.photos?.map {
            PlaceDetails.PhotoRef(
                reference: $0.photo_reference,
                width: $0.width,
                height: $0.height
            )
        } ?? [])
    }
}

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
    
    // MARK: - Helpers
    
    private let placeName = "mock"
    private let placeId = "mock"
    
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
