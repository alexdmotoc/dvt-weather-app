//
//  RemotePlaceDetailsFetcher.swift
//  WeatherApp
//
//  Created by Alex Motoc on 28.08.2023.
//

import Foundation

public protocol RemotePlaceDetailsFetcher {
    func fetchDetails(placeName: String) async throws -> PlaceDetails
}
