//
//  ForecastWeatherAPIDTO.swift
//  WeatherApp
//
//  Created by Alex Motoc on 20.08.2023.
//

import Foundation

struct ForecastWeatherAPIDTO: Codable {
    let list: [Item]
    
    struct Item: Codable {
        let main: Main
        let weather: [Weather]
    }
    
    struct Main: Codable {
        let temp: Double
    }
    
    struct Weather: Codable {
        let id: Int
    }
    
    var forecast: [WeatherInformation.Forecast] {
        list.map { .init(currentTemp: $0.main.temp, weatherType: .init(weatherId: $0.weather.first?.id)) }
    }
}
