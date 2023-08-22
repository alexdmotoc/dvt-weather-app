//
//  WeatherRepositoryTests.swift
//  WeatherAppTests
//
//  Created by Alex Motoc on 21.08.2023.
//

import XCTest
import WeatherApp

class WeatherRepositoryTests: XCTestCase {
    func test_init_doesntProduceSideEffects() {
        let (fetcher, cache, _) = makeSUT()
        
        XCTAssertEqual(fetcher.fetchCount, 0)
        XCTAssertEqual(cache.messages, [])
    }
    
    // MARK: - Get weather tests
    
    func test_getWeather_callsCacheCompletion() async throws {
        let (_, cache, sut) = makeSUT()
        let mockWeather = makeWeatherInformationArray()
        cache.stubbedWeather = mockWeather
        
        _ = try await sut.getWeather { cached in
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
    
    // MARK: - Add favourite location tests
    
    func test_addLocation_callsRemoteToFetchLocationAndAppendsFetchedLocationToCache() async throws {
        let (fetcher, cache, sut) = makeSUT()
        let remoteMock = makeWeatherInformationWithForecast()
        let cacheMock = makeWeatherInformationArray()
        fetcher.stub = (nil, remoteMock)
        cache.stubbedWeather = cacheMock
        
        let added = try await sut.addFavouriteLocation(coordinates: Self.makeLocation())
        
        XCTAssertEqual(fetcher.fetchCount, 1)
        XCTAssertEqual(added, remoteMock)
        XCTAssertEqual(cache.messages, [.load, .save(cacheMock + [remoteMock])])
    }
    
    // MARK: - Helpers
    
    private func assertSUTResults(
        currentLocation: @escaping () -> Coordinates? = makeLocation,
        cachedWeather: [WeatherInformation],
        remoteStub: WeatherInformation,
        resultsCount: Int
    ) async throws {
        let (fetcher, cache, sut) = makeSUT(currentLocation: currentLocation)
        cache.stubbedWeather = cachedWeather
        fetcher.stub = (nil, remoteStub)
        
        let results = try await sut.getWeather(cacheHandler: { _ in })
        
        let expectedResults = Array(repeating: remoteStub, count: resultsCount)
        XCTAssertEqual(fetcher.fetchCount, resultsCount)
        XCTAssertEqual(results, expectedResults)
        XCTAssertEqual(cache.messages, [.load, .save(expectedResults)])
    }
    
    private func makeSUT(
        currentLocation: @escaping () -> Coordinates? = makeLocation,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (fetcher: RemoteWeatherFetcherSpy, cache: WeatherCacheSpy, sut: WeatherRepository) {
        let fetcher = RemoteWeatherFetcherSpy(weatherInformation: makeWeatherInformationWithForecast())
        let cache = WeatherCacheSpy()
        let sut = WeatherRepositoryImpl(fetcher: fetcher, cache: cache, currentLocation: currentLocation)
        checkIsDeallocated(sut: fetcher, file: file, line: line)
        checkIsDeallocated(sut: cache, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (fetcher, cache, sut)
    }
    
    private static func makeLocation() -> Coordinates {
        .init(latitude: 10, longitude: 10)
    }
    
    private class RemoteWeatherFetcherSpy: RemoteWeatherFetcher {
        
        init(error: Error? = nil, weatherInformation: WeatherInformation? = nil) {
            stub = (error, weatherInformation)
        }
        
        var stub: (error: Error?, weather: WeatherInformation?) = (nil, nil)
        var fetchCount = 0
        
        func fetch(coordinates: Coordinates, isCurrentLocation: Bool) async throws -> WeatherInformation {
            fetchCount += 1
            if let error = stub.error { throw error }
            if let weather = stub.weather { return weather }
            throw NSError(domain: "spy", code: 0)
        }
    }
    
    private class WeatherCacheSpy: WeatherCache {
        enum Message: Equatable {
            case save([WeatherInformation])
            case load
        }
        
        var messages: [Message] = []
        var stubbedWeather: [WeatherInformation] = []
        
        func save(_ weather: [WeatherInformation]) throws {
            messages.append(.save(weather))
            stubbedWeather = weather
        }
        
        func load() throws -> [WeatherInformation] {
            messages.append(.load)
            return stubbedWeather
        }
    }
}
