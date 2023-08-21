//
//  WeatherRepositoryTests.swift
//  WeatherAppTests
//
//  Created by Alex Motoc on 21.08.2023.
//

import XCTest
import WeatherApp
import CoreLocation

final class WeatherRepositoryImpl: WeatherRepository {
    
    private let fetcher: RemoteWeatherFetcher
    private let cache: WeatherCache
    private let currentLocation: () -> CLLocationCoordinate2D
    
    init(fetcher: RemoteWeatherFetcher, cache: WeatherCache, currentLocation: @escaping () -> CLLocationCoordinate2D) {
        self.fetcher = fetcher
        self.cache = cache
        self.currentLocation = currentLocation
    }
    
    func getWeather(cacheHandler: ([WeatherInformation]) -> Void) async throws -> [WeatherInformation] {
        let weatherCache = try cache.load()
        cacheHandler(weatherCache)
        
        let currentWeather = try await fetcher.fetch(coordinates: currentLocation(), isCurrentLocation: true)
        var results = [currentWeather]
        for favouriteWeather in weatherCache.filter({ !$0.isCurrentLocation }) {
            let updatedFavouriteWeather = try await fetcher.fetch(coordinates: favouriteWeather.location.coordinates, isCurrentLocation: false)
            results.append(updatedFavouriteWeather)
        }
        
        try cache.save(results)
        
        return results
    }
    
    func addFavouriteLocation(coordinates: CLLocationCoordinate2D) async throws -> WeatherInformation {
        throw NSError(domain: "asd", code: 12)
    }
}

class WeatherRepositoryTests: XCTestCase {
    func test_init_doesntProduceSideEffects() {
        let (fetcher, cache, _) = makeSUT()
        
        XCTAssertEqual(fetcher.fetchCount, 0)
        XCTAssertEqual(cache.messages, [])
    }
    
    func test_getWeather_callsCacheCompletion() async throws {
        let (_, cache, sut) = makeSUT()
        let mockWeather = makeWeatherInformationArray()
        cache.stubbedWeather = mockWeather
        
        _ = try await sut.getWeather { cached in
            XCTAssertEqual(cached, mockWeather)
        }
    }
    
    func test_getWeather_getsWeatherAtCurrentLocation() async throws {
        let (fetcher, _, sut) = makeSUT()
        let mockRemoteWeather = makeWeatherInformationWithForecast()
        fetcher.stub = (nil, mockRemoteWeather)
        
        let results = try await sut.getWeather(cacheHandler: { _ in })
        
        XCTAssertEqual(fetcher.fetchCount, 1)
        XCTAssertEqual(results, [mockRemoteWeather])
    }
    
    func test_getWeather_getsWeatherAtFavouriteLocationsReplacingCurrentWeather() async throws {
        let (fetcher, cache, sut) = makeSUT()
        let mockCachedWeather = makeWeatherInformationArray()
        let mockRemoteWeather = makeWeatherInformationWithForecast()
        cache.stubbedWeather = mockCachedWeather
        fetcher.stub = (nil, mockRemoteWeather)
        
        let results = try await sut.getWeather(cacheHandler: { _ in })
        
        XCTAssertEqual(fetcher.fetchCount, mockCachedWeather.count)
        XCTAssertEqual(results, Array(repeating: mockRemoteWeather, count: mockCachedWeather.count))
    }
    
    func test_getWeather_replacesOldCache() async throws {
        let (fetcher, cache, sut) = makeSUT()
        let mockRemoteWeather = makeWeatherInformationWithForecast()
        fetcher.stub = (nil, mockRemoteWeather)
        
        let results = try await sut.getWeather(cacheHandler: { _ in })
        
        XCTAssertEqual(fetcher.fetchCount, 1)
        XCTAssertEqual(results, [mockRemoteWeather])
        XCTAssertEqual(cache.messages, [.load, .save([mockRemoteWeather])])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (fetcher: RemoteWeatherFetcherSpy, cache: WeatherCacheSpy, sut: WeatherRepository) {
        let fetcher = RemoteWeatherFetcherSpy(weatherInformation: makeWeatherInformationWithForecast())
        let cache = WeatherCacheSpy()
        let sut = WeatherRepositoryImpl(fetcher: fetcher, cache: cache, currentLocation: makeCurrentLocation)
        checkIsDeallocated(sut: fetcher, file: file, line: line)
        checkIsDeallocated(sut: cache, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (fetcher, cache, sut)
    }
    
    private func makeCurrentLocation() -> CLLocationCoordinate2D {
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
