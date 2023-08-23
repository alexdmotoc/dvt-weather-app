//
//  AppSettings.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 23.08.2023.
//

import Foundation

enum TemperatureType: Int, CaseIterable {
    case celsius, fahrenheit
    
    var unitTemperature: UnitTemperature {
        switch self {
        case .celsius: return .celsius
        case .fahrenheit: return .fahrenheit
        }
    }
}

final class AppSettings: ObservableObject {
    
    @Published var temperatureType: TemperatureType {
        didSet {
            UserDefaults.standard.set(temperatureType.rawValue, forKey: "com.AppSettings.tempType")
        }
    }
    
    init() {
        temperatureType = Self.currentTempType
    }
    
    private static var currentTempType: TemperatureType {
        let raw = UserDefaults.standard.integer(forKey: "com.AppSettings.tempType")
        return .init(rawValue: raw) ?? .celsius
    }
}
