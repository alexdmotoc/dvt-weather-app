//
//  ForecastViewModel.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 23.08.2023.
//

import Foundation
import WeatherApp

struct ForecastViewModel: Identifiable {
    let id = UUID()
    let forecast: WeatherInformation.Forecast
    let temperatureType: TemperatureType
    let index: Int
    
    var day: String {
        let date = Calendar.current.date(byAdding: .day, value: index, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEEE")
        return formatter.string(from: date)
    }
    
    var indicatorIconName: String {
        forecast.weatherType.indicatorIconName
    }
    
    var temperature: String {
        "\(convertTemperature(forecast.currentTemp, to: temperatureType.unitTemperature))º"
    }
}

private extension WeatherInformation.WeatherType {
    var indicatorIconName: String {
        switch self {
        case .sunny: return "clear"
        case .cloudy: return "partlysunny"
        case .rainy: return "rain"
        }
    }
}
