//
//  NullWeatherStore.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 22.08.2023.
//

import Foundation
import WeatherApp

/// Used in case the CoreData stack has an error when initializing.
///
final class NullWeatherStore: WeatherStore {
    func save(_ weather: [WeatherInformation]) throws {
        
    }
    
    func load() throws -> [WeatherInformation] {
        []
    }
    
    func deleteAllItems() throws {
        
    }
}
