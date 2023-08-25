//
//  WeatherInformation+Utils.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 24.08.2023.
//

import Foundation
import WeatherApp
import CoreLocation

extension WeatherInformation.WeatherType {
    var backgroundColorName: String {
        switch self {
        case .sunny: return "sunny"
        case .cloudy: return "cloudy"
        case .rainy: return "rainy"
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

extension Coordinates {
    var toCLCoordinates: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
}
