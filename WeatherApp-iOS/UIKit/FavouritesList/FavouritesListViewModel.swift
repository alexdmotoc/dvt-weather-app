//
//  FavouritesListViewModel.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 24.08.2023.
//

import Foundation
import WeatherApp
import MapKit
import Combine

@MainActor
final class FavouritesListViewModel {
    
    // MARK: - Private properties
    
    private let store: WeatherInformationStore
    private let useCase: FavouriteLocationUseCase
    private let appSettings: AppSettings
    private var settingsObservation: AnyCancellable?
    private var itemsObservation: AnyCancellable?
    private var localSearch: MKLocalSearch? {
        willSet {
            localSearch?.cancel()
        }
    }
    private var isInternallyModifyingStore = false
    
    // MARK: - Public properties
    
    private(set) var items: [FavouriteItemsListData.Item]
    var displayError: ((Swift.Error) -> Void)?
    var didReloadItems: (([FavouriteItemsListData.Item]) -> Void)?
    var didAppendItem: ((FavouriteItemsListData.Item) -> Void)?
    
    // MARK: - Lifecycle
    
    init(store: WeatherInformationStore, useCase: FavouriteLocationUseCase, appSettings: AppSettings) {
        self.store = store
        self.useCase = useCase
        self.appSettings = appSettings
        items = store.weatherInformation.map {
            $0.toListData(unitTemperature: appSettings.temperatureType.unitTemperature)
        }
        
        settingsObservation = appSettings.$temperatureType
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self, weak store] tempType in
                guard let self, let store else { return }
                self.items = store.weatherInformation.map { $0.toListData(unitTemperature: tempType.unitTemperature) }
                self.didReloadItems?(self.items)
            })
        
        itemsObservation = store.$weatherInformation
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] items in
                self?.handleItemChangeNotification(items: items)
            })
    }
    
    // MARK: - Public methods
    
    /// Performs  a search with `MKLocalSearch.Request` using this suggested completion.
    /// - Parameter suggestedCompletion: A search completion that `MKLocalSearchCompleter` provides.
    ///
    func search(for suggestedCompletion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: suggestedCompletion)
        search(using: searchRequest)
    }
    
    /// - Parameter queryString: A search string from the text the user enters into `UISearchBar`.
    /// 
    func search(for queryString: String?) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = queryString
        search(using: searchRequest)
    }
    
    func deleteItem(at index: Int) {
        guard items.indices.contains(index), store.weatherInformation.indices.contains(index) else { return }
        isInternallyModifyingStore = true
        items.remove(at: index)
        let item = store.weatherInformation.remove(at: index)
        do {
            try useCase.removeFavouriteLocation(item)
        } catch {
            displayError?(error)
        }
    }
    
    // MARK: - Private methods
    
    private func handleItemChangeNotification(items: [WeatherInformation]) {
        guard !isInternallyModifyingStore else {
            isInternallyModifyingStore = false
            return
        }
        self.items = items.map { $0.toListData(unitTemperature: appSettings.temperatureType.unitTemperature) }
        didReloadItems?(self.items)
    }
    
    private func search(using searchRequest: MKLocalSearch.Request) {
        searchRequest.region = MKCoordinateRegion(MKMapRect.world)
        searchRequest.resultTypes = .address
        
        localSearch = MKLocalSearch(request: searchRequest)
        localSearch?.start { [unowned self] (response, error) in
            guard error == nil, let location = response?.mapItems.first else {
                self.displayError?(Error.searchLocationFailed)
                return
            }
            Task {
                do {
                    try await addFavouriteLocation(coordinate: location.placemark.coordinate)
                } catch {
                    DispatchQueue.main.async { [weak self] in
                        self?.displayError?(error)
                    }
                }
            }
        }
    }
    
    @MainActor
    private func addFavouriteLocation(coordinate: CLLocationCoordinate2D) async throws {
        let location = try await useCase.addFavouriteLocation(
            coordinates: coordinate.weatherAppCoordinates
        )
        isInternallyModifyingStore = true
        store.weatherInformation.append(location)
        let listItem = location.toListData(unitTemperature: appSettings.temperatureType.unitTemperature)
        items.append(listItem)
        didAppendItem?(listItem)
    }
}

// MARK: - Errors

private extension FavouritesListViewModel {
    enum Error: Swift.Error, LocalizedError {
        case searchLocationFailed
        
        var errorDescription: String? {
            switch self {
            case .searchLocationFailed:
                return NSLocalizedString("error.searchLocationFailed.message", comment: "")
            }
        }
    }
}

// MARK: - WeatherInformation + Utils

private extension WeatherInformation {
    func toListData(unitTemperature: UnitTemperature) -> FavouriteItemsListData.Item {
        .init(
            locationName: location.name,
            isCurrentLocation: isCurrentLocation,
            weatherTypeTitleKey: weatherType.titleLocalizedKey,
            backgroundColorName: weatherType.backgroundColorName,
            currentTemperature: convertTemperature(temperature.current, to: unitTemperature),
            minTemperature: convertTemperature(temperature.min, to: unitTemperature),
            maxTemperature: convertTemperature(temperature.max, to: unitTemperature)
        )
    }
}
