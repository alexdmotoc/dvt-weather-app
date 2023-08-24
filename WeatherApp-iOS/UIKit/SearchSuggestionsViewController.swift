//
//  SearchSuggestionsViewController.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 24.08.2023.
//

import UIKit
import MapKit

class SearchSuggestionsViewController: UIViewController {
    
    // MARK: - Diffable data
    
    enum Section {
        case main
    }
    
    struct Row: Hashable {
        let searchCompletion: MKLocalSearchCompletion
    }
    
    // MARK: - Private properties
    
    private var searchCompleter: MKLocalSearchCompleter?
    private var dataSource: UICollectionViewDiffableDataSource<Section, Row>! = nil
    
    // MARK: - Public properties
    
    private(set) var collectionView: UICollectionView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        configureViewHierarchy()
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startProvidingCompletions()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopProvidingCompletions()
    }
    
    // MARK: - Public methods
    
    func item(at indexPath: IndexPath) -> Row? {
        dataSource.itemIdentifier(for: indexPath)
    }
    
    // MARK: - Private methods
    
    private func configureViewHierarchy() {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
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
    
    private func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { section, layoutEnvironment in
            let config = UICollectionLayoutListConfiguration(appearance: .grouped)
            return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
        }
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Row> { [weak self] cell, indexPath, item in
            var content = UIListContentConfiguration.subtitleCell()
            let suggestion = item.searchCompletion
            content.attributedText = self?.createHighlightedString(text: suggestion.title, rangeValues: suggestion.titleHighlightRanges)
            content.secondaryAttributedText = self?.createHighlightedString(text: suggestion.subtitle, rangeValues: suggestion.subtitleHighlightRanges)
            cell.contentConfiguration = content
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Row>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: Row) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }
    
    private func createHighlightedString(text: String, rangeValues: [NSValue]) -> NSAttributedString {
        let attributes = [NSAttributedString.Key.backgroundColor: UIColor.systemYellow]
        let highlightedString = NSMutableAttributedString(string: text)
        
        let ranges = rangeValues.map { $0.rangeValue }
        ranges.forEach { (range) in
            highlightedString.addAttributes(attributes, range: range)
        }
        
        return highlightedString
    }
    
    private func startProvidingCompletions() {
        searchCompleter = MKLocalSearchCompleter()
        searchCompleter?.delegate = self
        searchCompleter?.region = MKCoordinateRegion(MKMapRect.world)
        searchCompleter?.resultTypes = .address
    }
    
    private func stopProvidingCompletions() {
        searchCompleter = nil
    }
    
    private func updateCollectionViewSnapshot(_ rows: [Row]) {
        var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<Row>()
        sectionSnapshot.append(rows)
        dataSource.apply(sectionSnapshot, to: .main, animatingDifferences: true)
    }
}

// MARK: - MKLocalSearchCompleterDelegate

extension SearchSuggestionsViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let results = completer.results.map { result in
            Row(searchCompletion: result)
        }
        updateCollectionViewSnapshot(results)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        if let error = error as NSError? {
            print("MKLocalSearchCompleter encountered an error: \(error.localizedDescription). The query fragment is: \"\(completer.queryFragment)\"")
        }
    }
}

// MARK: - UISearchResultsUpdating

extension SearchSuggestionsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchCompleter?.queryFragment = searchController.searchBar.text ?? ""
    }
}
