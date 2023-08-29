//
//  PlacePhotoFetcher.swift
//  WeatherApp
//
//  Created by Alex Motoc on 29.08.2023.
//

import Foundation

public protocol PlacePhotoFetcher {
    func fetchPhoto(reference: String, minWidth: Int?, minHeight: Int?) async throws -> Data
}
