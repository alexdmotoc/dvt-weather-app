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
    
    private let defaults: UserDefaults
    private static let tempTypeKey = "com.AppSettings.tempType"
    
    @Published var temperatureType: TemperatureType {
        didSet {
            defaults.set(temperatureType.rawValue, forKey: Self.tempTypeKey)
        }
    }
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let raw = defaults.integer(forKey: Self.tempTypeKey)
        temperatureType = .init(rawValue: raw) ?? .celsius
    }
}
