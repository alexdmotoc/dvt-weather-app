//
//  PlacePhotoFetcher.swift
//  WeatherApp
//
//  Created by Alex Motoc on 29.08.2023.
//

import Foundation

public protocol PlacePhotoFetcher {
    func fetchPhoto(reference: String, maxWidth: Int, maxHeight: Int?) async throws -> Data
}

// MARK: - Implementation

public final class PlacePhotoFetcherImpl: PlacePhotoFetcher {
    
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func fetchPhoto(reference: String, maxWidth: Int, maxHeight: Int?) async throws -> Data {
        let request = try PlacesAPIURLRequestFactory.makeGetPhotoURLRequest(
            photoReference: reference,
            maxWidth: maxWidth,
            maxHeight: maxHeight
        )
        let (data, response) = try await client.load(urlReqeust: request)
        guard response.statusCode == 200, !data.isEmpty else { throw Error.invalidData }
        return data
    }
    
    // MARK: - Error
    
    public enum Error: Swift.Error, LocalizedError {
        case invalidData
        
        public var errorDescription: String? {
            switch self {
            case .invalidData:
                return NSLocalizedString(
                    "api.error.message",
                    bundle: Bundle(for: PlacePhotoFetcherImpl.self),
                    comment: ""
                )
            }
        }
    }
}
