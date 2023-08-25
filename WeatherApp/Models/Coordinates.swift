//
//  Coordinates.swift
//  WeatherApp
//
//  Created by Alex Motoc on 22.08.2023.
//

import Foundation
import CoreLocation

public struct Coordinates: Equatable {
    public let latitude: Double
    public let longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension Coordinates {
    public var toCLCoordinates: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
}
