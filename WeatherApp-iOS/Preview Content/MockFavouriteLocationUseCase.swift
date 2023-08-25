//
//  MockFavouriteLocationUseCase.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 23.08.2023.
//

import Foundation
import WeatherApp

class MockFavouriteLocationUseCase: FavouriteLocationUseCase {
    
    struct Stub {
        let result: WeatherInformation?
        let error: Error?
    }
    
    var stub: Stub?
    var addFavouriteCallCount = 0
    
    private let noStubError = NSError(domain: "no stub", code: 0)
    
    func addFavouriteLocation(coordinates: Coordinates) async throws -> WeatherInformation {
        addFavouriteCallCount += 1
        guard let stub else { throw noStubError }
        if let error = stub.error { throw error }
        if let result = stub.result { return result }
        throw noStubError
    }
    
    func removeFavouriteLocation(_ location: WeatherInformation) throws {
        
    }
}
