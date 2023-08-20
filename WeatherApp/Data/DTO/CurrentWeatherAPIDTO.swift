//
//  CurrentWeatherAPIDTO.swift
//  WeatherApp
//
//  Created by Alex Motoc on 20.08.2023.
//

import Foundation

struct CurrentWeatherAPIDTO: Codable {
    let coord: Coordinates
    let weather: [Weather]
    let main: Main
    let name: String
    
    struct Coordinates: Codable {
        let lat: Double
        let lon: Double
    }
    
    struct Weather: Codable {
        let id: Int
    }
    
    struct Main: Codable {
        let temp: Double
        let temp_min: Double
        let temp_max: Double
    }
}

extension CurrentWeatherAPIDTO {
    func weatherInformation(with forecast: [WeatherInformation.Forecast]) -> WeatherInformation {
        let weatherType = WeatherInformation.WeatherType(weatherId: weather.first?.id)
        return WeatherInformation(
            location: .init(
                name: name,
                coordinates: .init(latitude: coord.lat, longitude: coord.lon)
            ),
            temperature: .init(
                current: main.temp,
                min: main.temp_min,
                max: main.temp_max
            ), weatherType: weatherType,
            forecast: forecast
        )
    }
}
