//
//  CoordinatesTests.swift
//  WeatherAppTests
//
//  Created by Alex Motoc on 22.08.2023.
//

import XCTest
import WeatherApp

class CoordinatesTests: XCTestCase {
    func test_coordinates_areMappedCorrectlyToCLCoordinates() {
        let latitude: Double = 12.3456789
        let longitude: Double = 12.3456789
        
        let coordinates = Coordinates(latitude: latitude, longitude: longitude)
        
        XCTAssertEqual(coordinates.toCLCoordinates.latitude, latitude)
        XCTAssertEqual(coordinates.toCLCoordinates.longitude, longitude)
    }
}
