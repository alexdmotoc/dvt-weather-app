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

// MARK: - Implementation

public final class RemotePlaceDetailsFetcherImpl: RemotePlaceDetailsFetcher {
    
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func fetchDetails(placeName: String) async throws -> PlaceDetails {
        let response = try await fetchPlace(name: placeName)
        guard let placeId = response.results.first?.place_id else { throw Error.placeNotFound }
        let details = try await fetchPlaceDetails(placeId: placeId)
        return details.toLocal
    }
    
    private func fetchPlace(name: String) async throws -> PlaceResponseDTO {
        let request = try PlacesAPIURLRequestFactory.makeGetPlaceURLRequest(query: name)
        let (data, response) = try await client.load(urlReqeust: request)
        return try DataMapper.map(data: data, response: response)
    }
    
    private func fetchPlaceDetails(placeId: String) async throws -> PlaceDetailsDTO {
        let request = try PlacesAPIURLRequestFactory.makeGetPlaceDetailsURLRequest(placeId: placeId)
        let (data, response) = try await client.load(urlReqeust: request)
        return try DataMapper.map(data: data, response: response)
    }
    
    // MARK: - Error
    
    public enum Error: Swift.Error, LocalizedError {
        case invalidData
        case placeNotFound
        
        public var errorDescription: String? {
            switch self {
            case .invalidData:
                return NSLocalizedString(
                    "api.error.message",
                    bundle: Bundle(for: RemotePlaceDetailsFetcherImpl.self),
                    comment: ""
                )
            case .placeNotFound:
                return NSLocalizedString(
                    "api.places.error.notFound",
                    bundle: Bundle(for: RemotePlaceDetailsFetcherImpl.self),
                    comment: ""
                )
            }
        }
    }
    
    // MARK: - DataMapper
    
    private enum DataMapper {
        static func map<T: Decodable>(data: Data, response: HTTPURLResponse) throws -> T {
            guard
                response.statusCode == 200,
                let mapped = try? JSONDecoder().decode(T.self, from: data)
            else { throw Error.invalidData }
            return mapped
        }
    }
}
