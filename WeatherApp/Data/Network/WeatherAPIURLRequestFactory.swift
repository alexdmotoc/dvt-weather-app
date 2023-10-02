//
//  WeatherAPIURLRequestFactory.swift
//  WeatherApp
//
//  Created by Alex Motoc on 19.08.2023.
//

import Foundation

public enum WeatherAPIURLRequestFactory {
    public static func makeURLRequest(
        path: String,
        coordinates: Coordinates,
        appId: String = "e7550ddf86286a184072ad3828a1de20"
    ) throws -> URLRequest {
        let endpoint = Endpoint(
            baseURL: "https://api.openweathermap.org/data/2.5",
            path: path,
            queryParameters: [
                "lat": String(format: "%.5f", coordinates.latitude),
                "lon": String(format: "%.5f", coordinates.longitude),
                "appid": appId
            ]
        )
        return try endpoint.makeUrlRequest()
    }
}
