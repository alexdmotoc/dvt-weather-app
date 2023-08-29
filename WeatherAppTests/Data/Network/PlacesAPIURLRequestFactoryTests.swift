//
//  PlacesAPIURLRequestFactoryTests.swift
//  WeatherAppTests
//
//  Created by Alex Motoc on 28.08.2023.
//

import XCTest
import WeatherApp

class PlacesAPIURLRequestFactoryTests: XCTestCase {
    func test_factory_buildsCorrectRequestForGetPlace() throws {
        let request = try PlacesAPIURLRequestFactory.makeGetPlaceURLRequest(query: "mockQuery", apiKey: "mockApiKey")
        
        XCTAssertEqual(request.url?.absoluteString, "https://maps.googleapis.com/maps/api/place/textsearch/json?key=mockApiKey&query=mockQuery")
    }
    
    func test_factory_buildsCorrectRequestForGetPlaceDetails() throws {
        let request = try PlacesAPIURLRequestFactory.makeGetPlaceDetailsURLRequest(placeId: "mockPlaceId", apiKey: "mockApiKey")
        
        XCTAssertEqual(request.url?.absoluteString, "https://maps.googleapis.com/maps/api/place/details/json?key=mockApiKey&place_id=mockPlaceId")
    }
    
    func test_factory_buildsCorrectRequestForGetPhotosWithMaxWidthExtraParameters() throws {
        let request = try PlacesAPIURLRequestFactory.makeGetPhotoURLRequest(photoReference: "mockReference", maxWidth: 123, apiKey: "mockApiKey")
        
        XCTAssertEqual(request.url?.absoluteString, "https://maps.googleapis.com/maps/api/place/photo?key=mockApiKey&maxwidth=123&photo_reference=mockReference")
    }
    
    func test_factory_buildsCorrectRequestForGetPhotosWithMaxWidthMaxHeightExtraParameters() throws {
        let request = try PlacesAPIURLRequestFactory.makeGetPhotoURLRequest(photoReference: "mockReference", maxWidth: 123, maxHeight: 123, apiKey: "mockApiKey")
        
        XCTAssertEqual(request.url?.absoluteString, "https://maps.googleapis.com/maps/api/place/photo?key=mockApiKey&maxheight=123&maxwidth=123&photo_reference=mockReference")
    }
}
