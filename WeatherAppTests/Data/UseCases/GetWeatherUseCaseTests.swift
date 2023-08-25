//
//  GetWeatherUseCaseTests.swift
//  WeatherAppTests
//
//  Created by Alex Motoc on 23.08.2023.
//

import XCTest
@testable import WeatherApp

class GetWeatherUseCaseTests: XCTestCase {
    func test_init_doesntProduceSideEffects() {
        let (fetcher, cache, _) = makeSUT()
        
        XCTAssertEqual(fetcher.fetchCount, 0)
        XCTAssertEqual(cache.messages, [])
    }
    
    func test_getWeather_callsCacheCompletion() async throws {
        let (_, cache, sut) = makeSUT()
        let mockWeather = makeWeatherInformationArray()
        cache.stubbedWeather = mockWeather
        
        _ = try await sut.getWeather(currentLocation: Self.makeLocation()) { cached in
            XCTAssertEqual(cached, mockWeather)
        }
    }
    
    func test_getWeather_getsWeatherAtFavouriteLocationsReplacingCurrentWeather() async throws {
        let cacheMock = makeWeatherInformationArray(name: "cached")
        let remoteMock = makeWeatherInformationWithForecast(name: "remote")
        try await assertSUTResults(cachedWeather: cacheMock, remoteStub: remoteMock, resultsCount: cacheMock.count)
    }
    
    func test_getWeather_replacesOldCache() async throws {
        try await assertSUTResults(cachedWeather: [], remoteStub: makeWeatherInformationWithForecast(), resultsCount: 1)
    }
    
    func test_getWeather_doesNotFetchCurrentLocationIfNotAvailable() async throws {
        let remoteMock = makeWeatherInformationWithForecast()
        let cacheMock = makeWeatherInformationArray()
        // expected results is count - 1 because the current location is removed and not added back, since there is no location
        try await assertSUTResults(currentLocation: { nil }, cachedWeather: cacheMock, remoteStub: remoteMock, resultsCount: cacheMock.count - 1)
    }
    
    func test_getSortedResults_sortsTheReceivedResultsToPreserveOrderOfInitial() {
        let cache = [
            makeWeatherInformation(locationName: "curr loc", isCurrentLocation: true, coordinates: .init(latitude: -1, longitude: -1), sortOrder: 0),
            makeWeatherInformation(locationName: "loc 1", coordinates: .init(latitude: 1, longitude: 1), sortOrder: 0),
            makeWeatherInformation(locationName: "loc 2", coordinates: .init(latitude: 2, longitude: 2), sortOrder: 1),
            makeWeatherInformation(locationName: "loc 3", coordinates: .init(latitude: 3, longitude: 3), sortOrder: 2),
            makeWeatherInformation(locationName: "loc 4", coordinates: .init(latitude: 4, longitude: 4), sortOrder: 3)
        ]
        
        let fetched = [
            makeWeatherInformation(locationName: "loc 3", coordinates: .init(latitude: 3, longitude: 3)),
            makeWeatherInformation(locationName: "loc 1", coordinates: .init(latitude: 1, longitude: 1)),
            makeWeatherInformation(locationName: "curr loc", isCurrentLocation: true, coordinates: .init(latitude: -1, longitude: -1)),
            makeWeatherInformation(locationName: "loc 4", coordinates: .init(latitude: 4, longitude: 4)),
            makeWeatherInformation(locationName: "loc 2", coordinates: .init(latitude: 2, longitude: 2))
        ]
        
        let sorted = GetWeatherUseCaseImpl.getSortedResults(weatherCache: cache, results: fetched)
        
        // in the end they have to be sorted the same
        XCTAssertEqual(sorted, cache)
    }
    
    // MARK: - Helpers
    
    private func assertSUTResults(
        currentLocation: @escaping () -> Coordinates? = makeLocation,
        cachedWeather: [WeatherInformation],
        remoteStub: WeatherInformation,
        resultsCount: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws {
        let (fetcher, cache, sut) = makeSUT()
        cache.stubbedWeather = cachedWeather
        fetcher.stub = (nil, remoteStub)
        
        let results = try await sut.getWeather(currentLocation: currentLocation(), cacheHandler: { _ in })
        
        let expectedResults = Array(repeating: remoteStub, count: resultsCount)
        XCTAssertEqual(fetcher.fetchCount, resultsCount, file: file, line: line)
        XCTAssertEqual(results, expectedResults, file: file, line: line)
        XCTAssertEqual(cache.messages, [.load, .save(expectedResults)], file: file, line: line)
    }
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (fetcher: RemoteWeatherFetcherSpy, cache: WeatherCacheSpy, sut: GetWeatherUseCaseImpl) {
        let fetcher = RemoteWeatherFetcherSpy(weatherInformation: makeWeatherInformationWithForecast())
        let cache = WeatherCacheSpy()
        let sut = GetWeatherUseCaseImpl(fetcher: fetcher, cache: cache)
        checkIsDeallocated(sut: fetcher, file: file, line: line)
        checkIsDeallocated(sut: cache, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (fetcher, cache, sut)
    }   
}
