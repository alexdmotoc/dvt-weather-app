//
//  WeatherInformation.swift
//  WeatherApp
//
//  Created by Alex Motoc on 19.08.2023.
//

import Foundation
import CoreLocation

public struct WeatherInformation {
    public let location: Location
    public let temperature: Temperature
    public let weatherType: WeatherType
    public let forecast: [Forecast]
    
    public init(location: Location, temperature: Temperature, weatherType: WeatherType, forecast: [Forecast]) {
        self.location = location
        self.temperature = temperature
        self.weatherType = weatherType
        self.forecast = forecast
    }
}

// MARK: - Subtypes

extension WeatherInformation {
    public struct Location {
        public let name: String
        public let coordinates: CLLocationCoordinate2D
        
        public init(name: String, coordinates: CLLocationCoordinate2D) {
            self.name = name
            self.coordinates = coordinates
        }
    }
    
    public struct Temperature {
        public let current: Double
        public let min: Double
        public let max: Double
        
        public init(current: Double, min: Double, max: Double) {
            self.current = current
            self.min = min
            self.max = max
        }
    }
    
    public struct Forecast {
        public let day: String
        public let currentTemp: Double
        public let weatherType: WeatherType
        
        public init(day: String, currentTemp: Double, weatherType: WeatherType) {
            self.day = day
            self.currentTemp = currentTemp
            self.weatherType = weatherType
        }
    }
    
    public enum WeatherType {
        case sunny, cloudy, rainy
    }
}
