//
//  WeatherCacheSpy.swift
//  WeatherAppTests
//
//  Created by Alex Motoc on 23.08.2023.
//

import Foundation
import WeatherApp

class WeatherCacheSpy: WeatherCache {
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
