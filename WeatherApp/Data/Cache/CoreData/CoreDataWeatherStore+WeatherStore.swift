//
//  CoreDataWeatherStore+WeatherStore.swift
//  WeatherApp
//
//  Created by Alex Motoc on 21.08.2023.
//

import Foundation

extension CoreDataWeatherStore: WeatherStore {
    public func save(_ weather: [WeatherInformation]) throws {
        
    }
    
    public func load() throws -> [WeatherInformation] {
        []
    }
    
    public func deleteAllItems() throws {
        
    }
}
