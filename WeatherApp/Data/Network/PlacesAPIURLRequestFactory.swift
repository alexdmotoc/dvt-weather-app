//
//  PlacesAPIURLRequestFactory.swift
//  WeatherApp
//
//  Created by Alex Motoc on 28.08.2023.
//

import Foundation

public enum PlacesAPIURLRequestFactory {
    public static func makeGetPlaceURLRequest(
        query: String,
        apiKey: String = "AIzaSyDT08Q1TUdrMQRRRcdyzkn8idQ0YxEBUIo"
    ) throws -> URLRequest {
        let endpoint = Endpoint(
            baseURL: "https://maps.googleapis.com/maps/api/place",
            path: "/textsearch/json",
            queryParameters: [
                "query": query,
                "key": apiKey
            ]
        )
        return try endpoint.makeUrlRequest()
    }
    
    public static func makeGetPlaceDetailsURLRequest(
        placeId: String,
        apiKey: String = "AIzaSyDT08Q1TUdrMQRRRcdyzkn8idQ0YxEBUIo"
    ) throws -> URLRequest {
        let endpoint = Endpoint(
            baseURL: "https://maps.googleapis.com/maps/api/place",
            path: "/details/json",
            queryParameters: [
                "place_id": placeId,
                "key": apiKey
            ]
        )
        return try endpoint.makeUrlRequest()
    }
}
