//
//  PlaceDetailsViewModel.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 29.08.2023.
//

import Foundation
import WeatherApp

final class PlaceDetailsViewModel {
    let locationName: String
    private let detailsFetcher: RemotePlaceDetailsFetcher
    private let photoFetcher: PlacePhotoFetcher
    
    init(
        locationName: String,
        detailsFetcher: RemotePlaceDetailsFetcher,
        photoFetcher: PlacePhotoFetcher
    ) {
        self.locationName = locationName
        self.detailsFetcher = detailsFetcher
        self.photoFetcher = photoFetcher
    }
}
