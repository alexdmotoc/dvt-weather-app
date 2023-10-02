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
        apiKey: String? = nil
    ) throws -> URLRequest {
        let endpoint = Endpoint(
            baseURL: PlacesAPIConstants.baseURL,
            path: "/textsearch/json",
            queryParameters: [
                "query": query,
                "key": apiKey ?? PlacesAPIConstants.apiKey
            ]
        )
        return try endpoint.makeUrlRequest()
    }
    
    public static func makeGetPlaceDetailsURLRequest(
        placeId: String,
        apiKey: String? = nil
    ) throws -> URLRequest {
        let endpoint = Endpoint(
            baseURL: PlacesAPIConstants.baseURL,
            path: "/details/json",
            queryParameters: [
                "place_id": placeId,
                "key": apiKey ?? PlacesAPIConstants.apiKey
            ]
        )
        return try endpoint.makeUrlRequest()
    }
    
    public static func makeGetPhotoURLRequest(
        photoReference: String,
        maxWidth: Int,
        maxHeight: Int? = nil,
        apiKey: String? = nil
    ) throws -> URLRequest {
        var queryParams = [
            "photo_reference": photoReference,
            "maxwidth": String(maxWidth),
            "key": apiKey ?? PlacesAPIConstants.apiKey
        ]
        if let maxHeight { queryParams["maxheight"] = String(maxHeight) }
        let endpoint = Endpoint(
            baseURL: PlacesAPIConstants.baseURL,
            path: "/photo",
            queryParameters: queryParams
        )
        return try endpoint.makeUrlRequest()
    }
}
