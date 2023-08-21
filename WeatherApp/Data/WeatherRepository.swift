//
//  WeatherRepository.swift
//  WeatherApp
//
//  Created by Alex Motoc on 21.08.2023.
//

import Foundation
import CoreLocation

public protocol WeatherRepository {
    func getWeather(cacheHandler: ([WeatherInformation]) -> Void) async throws -> [WeatherInformation]
    func addFavouriteLocation(coordinates: CLLocationCoordinate2D) async throws -> WeatherInformation
}
