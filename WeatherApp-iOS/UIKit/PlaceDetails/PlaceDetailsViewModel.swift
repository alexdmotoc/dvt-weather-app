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
    let photoFetcher: PlacePhotoFetcher
    private let detailsFetcher: RemotePlaceDetailsFetcher
    
    var didLoadDetails: (([Item]) -> Void)?
    var didEncounterError: ((Error) -> Void)?
    
    init(
        locationName: String,
        detailsFetcher: RemotePlaceDetailsFetcher,
        photoFetcher: PlacePhotoFetcher
    ) {
        self.locationName = locationName
        self.detailsFetcher = detailsFetcher
        self.photoFetcher = photoFetcher
    }
    
    func loadDetails() {
        Task {
            do {
                let details = try await detailsFetcher.fetchDetails(placeName: locationName)
                DispatchQueue.main.async {
                    self.didLoadDetails?(details.photoRefs.map {
                        .init(reference: $0.reference, width: $0.width, height: $0.height)
                    })
                }
            } catch {
                didEncounterError?(error)
            }
        }
    }
}

// MARK: - Diffable Data

extension PlaceDetailsViewModel {
    enum Section {
        case main
    }
    
    struct Item: Hashable {
        let reference: String
        let width: Int
        let height: Int
    }
}
