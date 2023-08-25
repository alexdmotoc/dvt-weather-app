//
//  Coordinates.swift
//  WeatherApp
//
//  Created by Alex Motoc on 22.08.2023.
//

import Foundation

public struct Coordinates: Equatable {
    public let latitude: Double
    public let longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
