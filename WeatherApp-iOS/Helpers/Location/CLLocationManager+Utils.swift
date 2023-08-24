//
//  LocationManager.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 22.08.2023.
//

import Foundation
import CoreLocation

extension CLLocationManager {
    var isAuthorized: Bool {
        authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse
    }
}
