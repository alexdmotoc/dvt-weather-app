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
    // swiftlint:disable:next line_length
    private var dataSource: UICollectionViewDiffableDataSource<FavouriteItemsListData.Section, FavouriteItemsListData.Item>! = nil
    private var collectionView: UICollectionView!
    
    // MARK: - Public properties
    
    var didSelectPlaceNamed: ((String) -> Void)?
    
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
        view.backgroundColor = .systemGroupedBackground
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
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        
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
        // swiftlint:disable:next line_length
        let cellRegistration = UICollectionView.CellRegistration<FavouritesListCell, FavouriteItemsListData.Item> { cell, indexPath, item in
            cell.titleLabel.text = item.isCurrentLocation
            ? NSLocalizedString("currentLocation.title", comment: "")
            : item.locationName
            
            cell.subtitleLabel.text = item.isCurrentLocation
            ? item.locationName
            : NSLocalizedString(item.weatherTypeTitleKey, comment: "").localizedCapitalized
            
            cell.currentTemperatureLabel.text = "\(item.currentTemperature)º"
            cell.minTemperatureLabel.text = String(
                format: NSLocalizedString("temperature.cell.min.format", comment: ""), "\(item.minTemperature)º"
            )
            cell.maxTemperatureLabel.text = String(
                format: NSLocalizedString("temperature.cell.max.format", comment: ""), "\(item.maxTemperature)º"
            )
            cell.contentView.backgroundColor = UIColor(named: item.backgroundColorName)
        }
        
        // swiftlint:disable:next line_length
        let headerRegistration = UICollectionView.SupplementaryRegistration<FavouritesListHeader>(elementKind: UICollectionView.elementKindSectionHeader) { _, _, _ in }
        
        // swiftlint:disable:next line_length
        dataSource = UICollectionViewDiffableDataSource<FavouriteItemsListData.Section, FavouriteItemsListData.Item>(collectionView: collectionView) {
            collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        dataSource.supplementaryViewProvider = { [weak self] in
            self?.collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: $2)
        }
        
        didReloadItems(viewModel.items)
    }
    
    private func bindViewModel() {
        viewModel.displayError = displayError
        viewModel.didReloadItems = didReloadItems
        viewModel.didAppendItem = didAppendItem
    }
    
    private func displayError(_ error: Swift.Error) {
        let alertTitle = NSLocalizedString("error.title", comment: "")
        let alertController = UIAlertController(
            title: alertTitle,
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: NSLocalizedString("dismiss.title", comment: ""), style: .cancel)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func didReloadItems(_ items: [FavouriteItemsListData.Item]) {
        var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<FavouriteItemsListData.Item>()
        sectionSnapshot.append(items)
        dataSource.apply(sectionSnapshot, to: .main, animatingDifferences: true)
    }
    
    private func didAppendItem(_ item: FavouriteItemsListData.Item) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems([item])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - UICollectionViewDelegate

extension FavouritesListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if
            collectionView == suggestionController.collectionView,
            let row = suggestionController.item(at: indexPath)
        {
            searchController.isActive = false
            searchController.searchBar.text = ""
            viewModel.search(for: row.searchCompletion)
        } else if collectionView == self.collectionView {
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
            didSelectPlaceNamed?(item.locationName)
        }
        
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard dataSource.itemIdentifier(for: indexPath)?.isCurrentLocation == false else { return nil }
        
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let deleteAction = UIAction(
                title: NSLocalizedString("delete.title", comment: ""),
                image: UIImage(systemName: "trash.fill"),
                attributes: .destructive
            ) { [weak self] _ in
                self?.deleteItem(at: indexPath)
            }
            return UIMenu(title: "", children: [deleteAction])
        }
        return configuration
    }
    
    private func deleteItem(at indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([item])
        dataSource.apply(snapshot, animatingDifferences: true)
        viewModel.deleteItem(at: indexPath.row)
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
