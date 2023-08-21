//
//  WeatherCache.swift
//  WeatherApp
//
//  Created by Alex Motoc on 21.08.2023.
//

import Foundation

public protocol WeatherCache {
    func save(_ weather: [WeatherInformation]) throws
    func load() throws -> [WeatherInformation]
}
