//
//  WeatherCacheTests.swift
//  WeatherAppTests
//
//  Created by Alex Motoc on 21.08.2023.
//

import XCTest
import WeatherApp

class WeatherCacheTests: XCTestCase {
    
    func test_weatherCache_onInitDoesNothing() {
        let (store, _) = makeSUT()
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_weatherCache_onLoadOnceCallsLoadOnce() throws {
        let (store, cache) = makeSUT()
        
        _ = try cache.load()
        
        XCTAssertEqual(store.receivedMessages, [.load])
    }
    
    func test_weatherCache_onLoadTwiceCallsLoadTwice() throws {
        let (store, cache) = makeSUT()
        
        _ = try cache.load()
        _ = try cache.load()
        
        XCTAssertEqual(store.receivedMessages, [.load, .load])
    }
    
    func test_weatherCache_onSaveDeletesPreviousCacheAndSavesNewOne() throws {
        let (store, cache) = makeSUT()
        let mockData = [makeWeatherInformation()]
        
        try cache.save(mockData)
        
        XCTAssertEqual(store.receivedMessages, [.deleteAllItems, .save(mockData)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (store: WeatherStoreSpy, cache: WeatherCache) {
        let store = WeatherStoreSpy()
        let cache = WeatherCacheImpl(store: store)
        
        checkIsDeallocated(sut: store, file: file, line: line)
        checkIsDeallocated(sut: cache, file: file, line: line)
        
        return (store, cache)
    }
    
    private class WeatherStoreSpy: WeatherStore {
        
        enum ReceivedMessage: Equatable {
            case save([WeatherInformation])
            case load
            case deleteAllItems
        }
        
        var receivedMessages: [ReceivedMessage] = []
        var stubbedData: [WeatherInformation] = []
        
        func save(_ weather: [WeatherInformation]) throws {
            receivedMessages.append(.save(weather))
            stubbedData = weather
        }
        
        func load() throws -> [WeatherInformation] {
            receivedMessages.append(.load)
            return stubbedData
        }
        
        func deleteAllItems() throws {
            receivedMessages.append(.deleteAllItems)
        }
    }
}
