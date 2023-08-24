//
//  FavouritesListViewModel.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 24.08.2023.
//

import Foundation
import WeatherApp
import CoreLocation

final class FavouritesListViewModel {
    private let store: WeatherInformationStore
    private let useCase: FavouriteLocationUseCase
    
    init(store: WeatherInformationStore, useCase: FavouriteLocationUseCase) {
        self.store = store
        self.useCase = useCase
    }
    
    @MainActor
    func addFavouriteLocation(coordinate: CLLocationCoordinate2D) async throws {
        let location = try await useCase.addFavouriteLocation(coordinates: Coordinates(latitude: coordinate.latitude, longitude: coordinate.longitude))
        store.weatherInformation.append(location)
    }
}
