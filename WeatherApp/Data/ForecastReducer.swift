//
//  ForecastReducer.swift
//  WeatherApp
//
//  Created by Alex Motoc on 20.08.2023.
//

import Foundation

/// A namespace to contain the helper method to reduce a 3 hour forecast into daily average.
///
/// The API defined [here](https://openweathermap.org/forecast5) states
/// we will receive the forecast for 5 days in 3 hour steps,
/// so we expect to get 40 items (`5 days * 24 hours / 3 hours = 40 steps`)
///
public enum ForecastReducer {
    
    /// This algorithm works by splitting a 3 hour forecast into subarrays of 8 items (`3 * 8 = 24 => one day`) and
    /// computing the average for that subarray.
    /// The end result is an array where each item represents the forecast for one day.
    ///
    /// - Parameter forecast: a 3 hour step forecast
    /// - Returns: a daily averaged forecast
    ///
    public static func reduceHourlyForecastToDaily(
        _ forecast: [WeatherInformation.Forecast]
    ) -> [WeatherInformation.Forecast] {
        var startIndex = 0
        var reducedForecast: [WeatherInformation.Forecast] = []
        while startIndex < forecast.count {
            var temp: Double = 0
            var weatherTypeRaw = 0
            var iterations = 0
            for index in startIndex ..< min(startIndex + 8, forecast.count) {
                iterations += 1
                temp += forecast[index].currentTemp
                weatherTypeRaw += forecast[index].weatherType.rawValue
            }
            let averageTemp = temp / Double(iterations)
            let averageWeatherType = weatherTypeRaw / iterations
            let averageForecast = WeatherInformation.Forecast(
                currentTemp: averageTemp,
                weatherType: .init(rawValue: averageWeatherType) ?? .sunny
            )
            reducedForecast.append(averageForecast)
            startIndex += 8
        }
        return reducedForecast
    }
}
