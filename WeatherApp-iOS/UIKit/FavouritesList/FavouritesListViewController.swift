//
//  FavouritesListViewController.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 24.08.2023.
//

import UIKit

class FavouritesListViewController: UIViewController {
    
    // MARK: - Private properties
    
    private let viewModel: FavouritesListViewModel
    private var suggestionController: SearchSuggestionsViewController!
    private var searchController: UISearchController!
    private var dataSource: UICollectionViewDiffableDataSource<FavouriteItemsListData.Section, FavouriteItemsListData.Item>! = nil
    private var collectionView: UICollectionView!
    
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
        configureViewHierarchy()
        configureDataSource()
        bindViewModel()
    }
    
    // MARK: - Private methods
    
    private func configureSearchController() {
        suggestionController = SearchSuggestionsViewController()
        searchController = UISearchController(searchResultsController: suggestionController)
        searchController.searchResultsUpdater = suggestionController
        
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = NSLocalizedString("searchBar.placeholder", comment: "")
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    private func configureViewHierarchy() {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            view.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor)
        ])
        
        self.collectionView = collectionView
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<FavouritesListCell, FavouriteItemsListData.Item> { cell, indexPath, item in
            cell.titleLabel.text = item.locationName
            cell.subtitleLabel.text = "SUNNY"
            cell.currentTemperatureLabel.text = "\(item.currentTemperature)º"
            cell.minTemperatureLabel.text = "\(item.minTemperature)º"
            cell.maxTemperatureLabel.text = "\(item.maxTemperature)º"
        }
        
        dataSource = UICollectionViewDiffableDataSource<FavouriteItemsListData.Section, FavouriteItemsListData.Item>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: FavouriteItemsListData.Item) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        didReloadItems(viewModel.items)
    }
    
    private func bindViewModel() {
        viewModel.displayError = displayError
        viewModel.didReloadItems = didReloadItems
    }
    
    private func displayError(_ error: Swift.Error) {
        let alertTitle = NSLocalizedString("error.title", comment: "")
        let alertController = UIAlertController(title: alertTitle, message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("dismiss.title", comment: ""), style: .cancel)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func didReloadItems(_ items: [FavouriteItemsListData.Item]) {
        var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<FavouriteItemsListData.Item>()
        sectionSnapshot.append(items)
        dataSource.apply(sectionSnapshot, to: .main, animatingDifferences: true)
    }
}

extension FavouritesListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if
            collectionView == suggestionController.collectionView,
            let row = suggestionController.item(at: indexPath)
        {
            searchController.isActive = false
            searchController.searchBar.text = ""
            viewModel.search(for: row.searchCompletion)
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
        viewModel.search(for: searchBar.text)
        searchBar.text = ""
    }
}

// MARK: - UISearchControllerDelegate

extension FavouritesListViewController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        suggestionController.collectionView.delegate = self
    }
}