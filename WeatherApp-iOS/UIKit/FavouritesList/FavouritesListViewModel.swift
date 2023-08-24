//
//  FavouritesListViewModel.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 24.08.2023.
//

import Foundation
import WeatherApp
import CoreLocation
import MapKit

final class FavouritesListViewModel {
    
    // MARK: - Private properties
    
    private let store: WeatherInformationStore
    private let useCase: FavouriteLocationUseCase
    private var localSearch: MKLocalSearch? {
        willSet {
            localSearch?.cancel()
        }
    }
    
    // MARK: - Public properties
    
    var displayError: ((Swift.Error) -> Void)?
    
    // MARK: - Lifecycle
    
    init(store: WeatherInformationStore, useCase: FavouriteLocationUseCase) {
        self.store = store
        self.useCase = useCase
    }
    
    // MARK: - Public methods
    
    /// - Parameter suggestedCompletion: A search completion that `MKLocalSearchCompleter` provides.
    ///     This view controller performs  a search with `MKLocalSearch.Request` using this suggested completion.
    func search(for suggestedCompletion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: suggestedCompletion)
        search(using: searchRequest)
    }
    
    /// - Parameter queryString: A search string from the text the user enters into `UISearchBar`.
    func search(for queryString: String?) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = queryString
        search(using: searchRequest)
    }
    
    func search(using searchRequest: MKLocalSearch.Request) {
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
    
    // MARK: - Private methods
    
    @MainActor
    private func addFavouriteLocation(coordinate: CLLocationCoordinate2D) async throws {
        let location = try await useCase.addFavouriteLocation(coordinates: Coordinates(latitude: coordinate.latitude, longitude: coordinate.longitude))
        store.weatherInformation.append(location)
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
