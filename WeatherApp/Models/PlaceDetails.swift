//
//  PlaceDetails.swift
//  WeatherApp
//
//  Created by Alex Motoc on 28.08.2023.
//

import Foundation

public struct PlaceDetails: Equatable {
    public let photoRefs: [PhotoRef]
    
    public init(photoRefs: [PhotoRef]) {
        self.photoRefs = photoRefs
    }
    
    public struct PhotoRef: Equatable {
        public let reference: String
        public let width: Int
        public let height: Int
        
        public init(reference: String, width: Int, height: Int) {
            self.reference = reference
            self.width = width
            self.height = height
        }
    }
}
