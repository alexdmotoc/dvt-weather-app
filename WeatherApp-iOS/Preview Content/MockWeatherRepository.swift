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
    
    struct AddFavouriteLocationStub {
        let result: WeatherInformation?
        let error: Error?
    }
    
    var stub: GetWeatherStub?
    var favouriteStub: AddFavouriteLocationStub?
    
    var getWeatherCallCount = 0
    var addFavouriteCallCount = 0
    
    private let noStubError = NSError(domain: "no stub", code: 0)
    
    func getWeather(currentLocation: Coordinates?, cacheHandler: ([WeatherInformation]) -> Void) async throws -> [WeatherInformation] {
        getWeatherCallCount += 1
        guard let stub else { throw noStubError }
        if let error = stub.error { throw error }
        cacheHandler(stub.cache)
        return stub.result
    }
    
    func addFavouriteLocation(coordinates: Coordinates) async throws -> WeatherInformation {
        addFavouriteCallCount += 1
        guard let stub = favouriteStub else { throw noStubError }
        if let error = stub.error { throw error }
        if let result = stub.result { return result }
        throw noStubError
    }
}
