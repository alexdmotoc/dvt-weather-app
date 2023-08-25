//
//  CLLocation+Utils.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 25.08.2023.
//

import Foundation
import CoreLocation
import WeatherApp

extension CLLocationCoordinate2D {
    var weatherAppCoordinates: Coordinates {
        .init(latitude: latitude, longitude: longitude)
    }
}
