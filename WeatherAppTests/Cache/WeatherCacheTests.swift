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
        []
    }
}

class WeatherCacheTests: XCTestCase {
    
    func test_weatherCache_onInitDoesNothing() {
        let store = WeatherStoreSpy()
        _ = WeatherCacheImpl(store: store)
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    // MARK: - Helpers
    
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
