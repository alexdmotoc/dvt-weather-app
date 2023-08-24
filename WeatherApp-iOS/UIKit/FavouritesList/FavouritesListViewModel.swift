//
//  FavouritesListViewModel.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 24.08.2023.
//

import Foundation
import WeatherApp

final class FavouritesListViewModel {
    private let store: WeatherInformationStore
    private let useCase: FavouriteLocationUseCase
    
    init(store: WeatherInformationStore, useCase: FavouriteLocationUseCase) {
        self.store = store
        self.useCase = useCase
    }
}
