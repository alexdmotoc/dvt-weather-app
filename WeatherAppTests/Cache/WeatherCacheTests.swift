//
//  WeatherCacheTests.swift
//  WeatherAppTests
//
//  Created by Alex Motoc on 21.08.2023.
//

import XCTest
import WeatherApp

final class WeatherCacheImpl: WeatherCache {
    
    private let store: WeatherStore
    
    init(store: WeatherStore) {
        self.store = store
    }
    
    func save(_ weather: [WeatherInformation]) throws {
        
    }
    
    func load() throws -> [WeatherInformation] {
        try store.load()
    }
}

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
        var stubbedLoad: [WeatherInformation] = []
        
        func save(_ weather: [WeatherInformation]) throws {
            receivedMessages.append(.save(weather))
        }
        
        func load() throws -> [WeatherInformation] {
            receivedMessages.append(.load)
            return stubbedLoad
        }
        
        func deleteAllItems() throws {
            receivedMessages.append(.deleteAllItems)
        }
    }
}
