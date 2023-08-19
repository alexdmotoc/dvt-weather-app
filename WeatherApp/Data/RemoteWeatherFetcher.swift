//
//  RemoteWeatherFetcher.swift
//  WeatherApp
//
//  Created by Alex Motoc on 19.08.2023.
//

import Foundation
import CoreLocation

public protocol RemoteWeatherFetcher {
    func fetch(coordinates: CLLocationCoordinate2D) async throws -> WeatherInformation
}
