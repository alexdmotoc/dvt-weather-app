//
//  WeatherRepositoryTests.swift
//  WeatherAppTests
//
//  Created by Alex Motoc on 21.08.2023.
//

import XCTest
import WeatherApp
import CoreLocation

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
        try await assertSUTResults(cachedWeather: makeWeatherInformationArray(name: "cached"), remoteStub: makeWeatherInformationWithForecast(name: "remote"))
    }
    
    func test_getWeather_replacesOldCache() async throws {
        try await assertSUTResults(cachedWeather: [], remoteStub: makeWeatherInformationWithForecast())
    }
    
    // MARK: - Add favourite location tests
    
    func test_addLocation_callsRemoteToFetchLocationAndAppendsFetchedLocationToCache() async throws {
        let (fetcher, cache, sut) = makeSUT()
        let remoteMock = makeWeatherInformationWithForecast()
        let cacheMock = makeWeatherInformationArray()
        fetcher.stub = (nil, remoteMock)
        cache.stubbedWeather = cacheMock
        
        let added = try await sut.addFavouriteLocation(coordinates: makeLocation())
        
        XCTAssertEqual(fetcher.fetchCount, 1)
        XCTAssertEqual(added, remoteMock)
        XCTAssertEqual(cache.messages, [.load, .save(cacheMock + [remoteMock])])
    }
    
    // MARK: - Helpers
    
    private func assertSUTResults(cachedWeather: [WeatherInformation], remoteStub: WeatherInformation) async throws {
        let (fetcher, cache, sut) = makeSUT()
        cache.stubbedWeather = cachedWeather
        fetcher.stub = (nil, remoteStub)
        
        let results = try await sut.getWeather(cacheHandler: { _ in })
        
        let expectedResults = Array(repeating: remoteStub, count: max(cachedWeather.count, 1))
        XCTAssertEqual(fetcher.fetchCount, max(cachedWeather.count, 1))
        XCTAssertEqual(results, expectedResults)
        XCTAssertEqual(cache.messages, [.load, .save(expectedResults)])
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (fetcher: RemoteWeatherFetcherSpy, cache: WeatherCacheSpy, sut: WeatherRepository) {
        let fetcher = RemoteWeatherFetcherSpy(weatherInformation: makeWeatherInformationWithForecast())
        let cache = WeatherCacheSpy()
        let sut = WeatherRepositoryImpl(fetcher: fetcher, cache: cache, currentLocation: makeLocation)
        checkIsDeallocated(sut: fetcher, file: file, line: line)
        checkIsDeallocated(sut: cache, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (fetcher, cache, sut)
    }
    
    private func makeLocation() -> CLLocationCoordinate2D {
        .init(latitude: 10, longitude: 10)
    }
    
    private class RemoteWeatherFetcherSpy: RemoteWeatherFetcher {
        
        init(error: Error? = nil, weatherInformation: WeatherInformation? = nil) {
            stub = (error, weatherInformation)
        }
        
        var stub: (error: Error?, weather: WeatherInformation?) = (nil, nil)
        var fetchCount = 0
        
        func fetch(coordinates: CLLocationCoordinate2D, isCurrentLocation: Bool) async throws -> WeatherInformation {
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
