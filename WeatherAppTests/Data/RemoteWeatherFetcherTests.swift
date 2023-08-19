//
//  RemoteWeatherFetcherTests.swift
//  WeatherAppTests
//
//  Created by Alex Motoc on 19.08.2023.
//

import XCTest
import WeatherApp
import CoreLocation

final class RemoteWeatherFetcherImpl: RemoteWeatherFetcher {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func fetch(coordinates: CLLocationCoordinate2D) async throws -> WeatherInformation {
        WeatherInformation.makeMock()
    }
}

final class RemoteWeatherFetcherTests: XCTestCase {

    

}
