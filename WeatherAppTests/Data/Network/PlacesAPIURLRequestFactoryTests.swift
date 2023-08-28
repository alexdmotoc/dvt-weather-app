//
//  PlacesAPIURLRequestFactoryTests.swift
//  WeatherAppTests
//
//  Created by Alex Motoc on 28.08.2023.
//

import XCTest
import WeatherApp

class PlacesAPIURLRequestBuilderTests: XCTestCase {
    func test_builder_buildsCorrectRequestForGetPlace() throws {
        let request = try PlacesAPIURLRequestFactory.makeGetPlaceURLRequest(query: "mockQuery", apiKey: "mockApiKey")
        
        XCTAssertEqual(request.url?.absoluteString, "https://maps.googleapis.com/maps/api/place/textsearch/json?key=mockApiKey&query=mockQuery")
    }
    
    func test_builder_buildsCorrectRequestForGetPlaceDetails() throws {
        let request = try PlacesAPIURLRequestFactory.makeGetPlaceDetailsURLRequest(placeId: "mockPlaceId", apiKey: "mockApiKey")
        
        XCTAssertEqual(request.url?.absoluteString, "https://maps.googleapis.com/maps/api/place/details/json?key=mockApiKey&place_id=mockPlaceId")
    }
}
