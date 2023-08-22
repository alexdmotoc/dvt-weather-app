//
//  LocationManager.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 22.08.2023.
//

import Foundation
import CoreLocation

protocol LocationManager {
    var location: CLLocation? { get }
    var delegate: CLLocationManagerDelegate? { get set }
    var distanceFilter: CLLocationDistance { get set }
    var desiredAccuracy: CLLocationAccuracy { get set }
    var isAuthorized: Bool { get }
    
    func requestWhenInUseAuthorization()
    func startUpdatingLocation()
}

extension CLLocationManager: LocationManager {
    var isAuthorized: Bool {
        authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse
    }
}
