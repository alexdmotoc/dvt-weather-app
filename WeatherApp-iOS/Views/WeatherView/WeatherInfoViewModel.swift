//
//  WeatherInfoViewModel.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 23.08.2023.
//

import Foundation
import WeatherApp

struct WeatherInfoViewModel {
    enum TemperatureValue {
        case current, min, max
        
        var title: String {
            switch self {
            case .current: return NSLocalizedString("weatherValue.current.title", comment: "")
            case .min: return NSLocalizedString("weatherValue.min.title", comment: "")
            case .max: return NSLocalizedString("weatherValue.max.title", comment: "")
            }
        }
    }
    
    let info: WeatherInformation
    let temperatureType: TemperatureType
    
    var backgroundColorName: String {
        info.weatherType.backgroundColorName
    }
    
    var backgroundImageName: String {
        info.weatherType.backgroundImageName
    }
    
    var isEmpty: Bool {
        info.location.name == "--"
    }
    
    var formattedWeatherTitle: String {
        if isEmpty { return "--" }
        return NSLocalizedString(info.weatherType.titleLocalizedKey, comment: "")
    }
    
    var forecast: [ForecastViewModel] {
        info.forecast.enumerated().map { index, forecast in
            ForecastViewModel(forecast: forecast, temperatureType: temperatureType, index: index + 1)
        }
    }
    
    func formattedTemperature(type: TemperatureValue) -> String {
        if isEmpty { return "--" }
        let temp: Double
        switch type {
        case .current: temp = info.temperature.current
        case .min: temp = info.temperature.min
        case .max: temp = info.temperature.max
        }
        return "\(Int(convertTemperature(temp, to: temperatureType.unitTemperature)))º"
    }
}

private extension WeatherInformation.WeatherType {
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
    
    var titleLocalizedKey: String {
        switch self {
        case .sunny: return "sunny.title"
        case .cloudy: return "cloudy.title"
        case .rainy: return "rainy.title"
        }
    }
}
