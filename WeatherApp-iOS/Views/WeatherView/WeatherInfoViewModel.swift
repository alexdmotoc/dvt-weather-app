//
//  WeatherInfoViewModel.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 23.08.2023.
//

import Foundation
import WeatherApp

struct WeatherInfoViewModel {
    let info: WeatherInformation
    let temperatureType: TemperatureType
    
    var backgroundColorName: String {
        info.weatherType.backgroundColorName
    }
    
    var backgroundImageName: String {
        info.weatherType.backgroundImageName
    }
    
    var currentTemperature: Int {
        let measurement = Measurement<UnitTemperature>(value: info.temperature.current, unit: .kelvin)
            .converted(to: temperatureType.unitTemperature)
        return Int(measurement.value)
    }
}

extension WeatherInformation.WeatherType {
    var backgroundColorName: String {
        switch self {
        case .sunny: return "sunny"
        case .cloudy: return "cloudy"
        case .rainy: return "rainy"
        }
    }
    
    var backgroundImageName: String {
        switch self {
        case .sunny: return "forest_sunny"
        case .cloudy: return "forest_cloudy"
        case .rainy: return "forest_rainy"
        }
    }
    
    var indicatorIconName: String {
        switch self {
        case .sunny: return "clear"
        case .cloudy: return "partlysunny"
        case .rainy: return "rain"
        }
    }
}
