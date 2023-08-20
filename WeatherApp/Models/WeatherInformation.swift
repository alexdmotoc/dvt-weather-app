//
//  WeatherInformation.swift
//  WeatherApp
//
//  Created by Alex Motoc on 19.08.2023.
//

import Foundation
import CoreLocation

public struct WeatherInformation: Equatable {
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
    public struct Location: Equatable {
        public let name: String
        public let coordinates: CLLocationCoordinate2D
        
        public init(name: String, coordinates: CLLocationCoordinate2D) {
            self.name = name
            self.coordinates = coordinates
        }
    }
    
    public struct Temperature: Equatable {
        public let current: Double
        public let min: Double
        public let max: Double
        
        public init(current: Double, min: Double, max: Double) {
            self.current = current
            self.min = min
            self.max = max
        }
    }
    
    public struct Forecast: Equatable {
        public let currentTemp: Double
        public let weatherType: WeatherType
        
        public init(currentTemp: Double, weatherType: WeatherType) {
            self.currentTemp = currentTemp
            self.weatherType = weatherType
        }
    }
    
    /// For the sake of this problem, we only support sunny, cloudy and rainy weather types.
    /// Other weather types are blended with the existing ones, i.e. they will be reduced to .rainy.
    ///
    public enum WeatherType: Int {
        case sunny, cloudy, rainy
        
        /// Initialization with weather ID. The possible ID values are found [here](https://openweathermap.org/weather-conditions).
        /// Other weather types that are not supported are blended into the .rainy type (e.g. snow, mist, thunderstorm, etc).
        /// - Parameter weatherId: the weather ID
        ///
        public init(weatherId: Int?) {
            switch weatherId {
            case .none: self = .sunny
            case .some(let value):
                switch value {
                case ..<800: self = .rainy
                case 800: self = .sunny
                case 801...: self = .cloudy
                default: self = .sunny
                }
            }
        }
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
