//
//  FavouritesListViewController.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 24.08.2023.
//

import UIKit
import MapKit

class FavouritesListViewController: UIViewController {
    
    // MARK: - Private properties
    
    private let viewModel: FavouritesListViewModel
    private var suggestionController: SearchSuggestionsViewController!
    private var searchController: UISearchController!
    
    private var localSearch: MKLocalSearch? {
        willSet {
            localSearch?.cancel()
        }
    }
    
    // MARK: - Lifecycle
    
    init(viewModel: FavouritesListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("favourites.title", comment: "")
        configureSearchController()
    }
    
    // MARK: - Private methods
    
    private func configureSearchController() {
        suggestionController = SearchSuggestionsViewController()
        searchController = UISearchController(searchResultsController: suggestionController)
        searchController.searchResultsUpdater = suggestionController
        
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = NSLocalizedString("searchBar.placeholder", comment: "Search bar placeholder text")
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    /// - Parameter suggestedCompletion: A search completion that `MKLocalSearchCompleter` provides.
    ///     This view controller performs  a search with `MKLocalSearch.Request` using this suggested completion.
    private func search(for suggestedCompletion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: suggestedCompletion)
        search(using: searchRequest)
    }
    
    /// - Parameter queryString: A search string from the text the user enters into `UISearchBar`.
    private func search(for queryString: String?) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = queryString
        search(using: searchRequest)
    }
    
    private func search(using searchRequest: MKLocalSearch.Request) {
        searchRequest.region = MKCoordinateRegion(MKMapRect.world)
        searchRequest.resultTypes = .address
        
        localSearch = MKLocalSearch(request: searchRequest)
        localSearch?.start { [unowned self] (response, error) in
            guard error == nil, let location = response?.mapItems.first else {
                self.displayError(Error.searchLocationFailed)
                return
            }
            Task {
                do {
                    try await viewModel.addFavouriteLocation(coordinate: location.placemark.coordinate)
                } catch {
                    DispatchQueue.main.async { [weak self] in
                        self?.displayError(error)
                    }
                }
            }
        }
    }
    
    private func displayError(_ error: Swift.Error) {
        let alertTitle = NSLocalizedString("error.title", comment: "")
        let alertController = UIAlertController(title: alertTitle, message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("dismiss.title", comment: ""), style: .cancel)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension FavouritesListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if
            collectionView == suggestionController.collectionView,
            let row = suggestionController.dataSource.itemIdentifier(for: indexPath)
        {
            searchController.isActive = false
            searchController.searchBar.text = ""
            search(for: row.searchCompletion)
        }
        
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

// MARK: - UISearchBarDelegate

extension FavouritesListViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        // This system calls this method when the user taps Search on the `UISearchBar` or on the keyboard.
        // Because the user didn't select a row with a suggested completion, run the search with the query text in
        // the search field.
        search(for: searchBar.text)
        searchBar.text = ""
    }
}

// MARK: - UISearchControllerDelegate

extension FavouritesListViewController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        suggestionController.collectionView.delegate = self
    }
}

// MARK: - Errors

private extension FavouritesListViewController {
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
