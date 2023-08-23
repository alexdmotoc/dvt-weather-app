//
//  FavouriteLocationUseCaseTests.swift
//  WeatherAppTests
//
//  Created by Alex Motoc on 23.08.2023.
//

import Foundation
import XCTest
import WeatherApp

class FavouriteLocationUseCaseTests: XCTestCase {
    func test_init_doesntProduceSideEffects() {
        let (fetcher, cache, _) = makeSUT()
        
        XCTAssertEqual(fetcher.fetchCount, 0)
        XCTAssertEqual(cache.messages, [])
    }
    
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
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (fetcher: RemoteWeatherFetcherSpy, cache: WeatherCacheSpy, sut: FavouriteLocationUseCase) {
        let fetcher = RemoteWeatherFetcherSpy(weatherInformation: makeWeatherInformationWithForecast())
        let cache = WeatherCacheSpy()
        let sut = FavouriteLocationUseCaseImpl(fetcher: fetcher, cache: cache)
        checkIsDeallocated(sut: fetcher, file: file, line: line)
        checkIsDeallocated(sut: cache, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (fetcher, cache, sut)
    }
}
