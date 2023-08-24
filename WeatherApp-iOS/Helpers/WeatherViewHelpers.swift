//
//  WeatherViewHelpers.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 23.08.2023.
//

import Foundation

func convertTemperature(_ temp: Double, to unit: UnitTemperature) -> Int {
    let measurement = Measurement<UnitTemperature>(value: temp, unit: .kelvin).converted(to: unit)
    return Int(measurement.value)
}
