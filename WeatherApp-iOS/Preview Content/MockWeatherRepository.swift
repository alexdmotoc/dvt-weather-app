//
//  MockWeatherRepository.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 22.08.2023.
//

import Foundation
import WeatherApp

class MockWeatherRepository: WeatherRepository {
    
    struct GetWeatherStub {
        let cache: [WeatherInformation]
        let result: [WeatherInformation]
        let error: Error?
    }
    
    var stub: GetWeatherStub?
    
    private let noStubError = NSError(domain: "no stub", code: 0)
    
    func getWeather(cacheHandler: ([WeatherInformation]) -> Void) async throws -> [WeatherInformation] {
        guard let stub else { throw noStubError }
        if let error = stub.error { throw error }
        cacheHandler(stub.cache)
        return stub.result
    }
    
    func addFavouriteLocation(coordinates: Coordinates) async throws -> WeatherInformation {
        throw noStubError
    }
}
