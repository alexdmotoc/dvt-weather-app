//
//  MockWeatherRepository.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 22.08.2023.
//

import Foundation
import WeatherApp

class MockGetWeatherUseCase: GetWeatherUseCase {
    
    struct Stub {
        let cache: [WeatherInformation]
        let result: [WeatherInformation]
        let error: Error?
    }
    
    var stub: Stub?
    
    var getWeatherCallCount = 0
    
    private let noStubError = NSError(domain: "no stub", code: 0)
    
    func getWeather(currentLocation: Coordinates?, cacheHandler: ([WeatherInformation]) -> Void) async throws -> [WeatherInformation] {
        getWeatherCallCount += 1
        guard let stub else { throw noStubError }
        if let error = stub.error { throw error }
        cacheHandler(stub.cache)
        return stub.result
    }
}
