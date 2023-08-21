//
//  WeatherInformationMO+Mappings.swift
//  WeatherApp
//
//  Created by Alex Motoc on 21.08.2023.
//

import Foundation
import CoreData

// MARK: - From local to CoreData

extension WeatherInformationMO {
    static func insertedInto(_ context: NSManagedObjectContext, from weather: WeatherInformation, order: Int) -> WeatherInformationMO {
        let location = LocationMO(context: context)
        location.name = weather.location.name
        location.latitude = weather.location.coordinates.latitude
        location.longitude = weather.location.coordinates.longitude
        
        let temperature = TemperatureMO(context: context)
        temperature.current = weather.temperature.current
        temperature.min = weather.temperature.min
        temperature.max = weather.temperature.max
        
        let forecast = weather.forecast.map {
            let forecast = ForecastMO(context: context)
            forecast.currentTemp = $0.currentTemp
            forecast.weatherType = Int16($0.weatherType.rawValue)
            return forecast
        }
        
        let weatherMO = WeatherInformationMO(context: context)
        weatherMO.location = location
        weatherMO.temperature = temperature
        forecast.forEach { weatherMO.addToForecast($0) }
        weatherMO.order = Int32(order)
        weatherMO.weatherType = Int16(weather.weatherType.rawValue)
        return weatherMO
    }
}

// MARK: - From CoreData to local

extension WeatherInformationMO {
    var local: WeatherInformation {
        let location = self.location?.local ?? .init(name: "", coordinates: .init())
        let temperature = self.temperature?.local ?? .init(current: 0, min: 0, max: 0)
        let forecast = self.forecast?.compactMap { ($0 as? ForecastMO)?.local } ?? []
        return .init(
            location: location,
            temperature: temperature,
            weatherType: .init(rawValue: Int(weatherType)) ?? .sunny,
            forecast: forecast
        )
    }
}

extension LocationMO {
    var local: WeatherInformation.Location {
        .init(name: name ?? "", coordinates: .init(latitude: latitude, longitude: longitude))
    }
}

extension TemperatureMO {
    var local: WeatherInformation.Temperature {
        .init(current: current, min: min, max: max)
    }
}

extension ForecastMO {
    var local: WeatherInformation.Forecast {
        .init(currentTemp: currentTemp, weatherType: .init(rawValue: Int(weatherType)) ?? .sunny)
    }
}

