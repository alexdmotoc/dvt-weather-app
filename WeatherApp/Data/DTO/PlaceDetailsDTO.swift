//
//  PlaceDetailsDTO.swift
//  WeatherApp
//
//  Created by Alex Motoc on 28.08.2023.
//

import Foundation

struct PlaceResponseDTO: Decodable {
    let results: [Result]
    
    struct Result: Decodable {
        let place_id: String?
    }
}

struct PlaceDetailsDTO: Decodable {
    let result: Result
    
    struct Result: Decodable {
        let photos: [Photo]?
    }
    
    struct Photo: Decodable {
        let height: Int
        let width: Int
        let photo_reference: String
    }
    
    var toLocal: PlaceDetails {
        .init(photoRefs: result.photos?.map {
            PlaceDetails.PhotoRef(
                reference: $0.photo_reference,
                width: $0.width,
                height: $0.height
            )
        } ?? [])
    }
}
