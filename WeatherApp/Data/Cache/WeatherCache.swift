//
//  WeatherCache.swift
//  WeatherApp
//
//  Created by Alex Motoc on 21.08.2023.
//

import Foundation

public protocol WeatherCache {
    func save(_ weather: [WeatherInformation]) throws
    func load() throws -> [WeatherInformation]
}

// MARK: - Implementation

public final class WeatherCacheImpl: WeatherCache {
    
    private let store: WeatherStore
    
    public init(store: WeatherStore) {
        self.store = store
    }
    
    public func save(_ weather: [WeatherInformation]) throws {
        try store.deleteAllItems()
        try store.save(weather)
    }
    
    public func load() throws -> [WeatherInformation] {
        try store.load()
    }
}
