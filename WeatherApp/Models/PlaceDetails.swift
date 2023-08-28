//
//  PlaceDetails.swift
//  WeatherApp
//
//  Created by Alex Motoc on 28.08.2023.
//

import Foundation

public struct PlaceDetails {
    public let photoRefs: [PhotoRef]
    
    public struct PhotoRef {
        let reference: String
        let width: Int
        let height: Int
    }
}
