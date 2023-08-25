//
//  RemoteWeatherFetcherSpy.swift
//  WeatherAppTests
//
//  Created by Alex Motoc on 23.08.2023.
//

import Foundation
import WeatherApp

class RemoteWeatherFetcherSpy: RemoteWeatherFetcher {
   
   init(error: Error? = nil, weatherInformation: WeatherInformation? = nil) {
       stub = (error, weatherInformation)
   }
   
   var stub: (error: Error?, weather: WeatherInformation?) = (nil, nil)
   var fetchCount = 0
   
   func fetch(coordinates: Coordinates, isCurrentLocation: Bool) async throws -> WeatherInformation {
       fetchCount += 1
       if let error = stub.error { throw error }
       if let weather = stub.weather { return weather }
       throw NSError(domain: "spy", code: 0)
   }
}
