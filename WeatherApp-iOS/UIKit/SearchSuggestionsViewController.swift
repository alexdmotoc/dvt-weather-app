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
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Row>! = nil
    private var collectionView: UICollectionView!
    private let searchRegion = MKCoordinateRegion(MKMapRect.world)
    private var searchCompleter: MKLocalSearchCompleter?
    
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
            var config = UICollectionLayoutListConfiguration(appearance: .grouped)
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
        searchCompleter?.region = searchRegion
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
        // Handle any errors that `MKLocalSearchCompleter` returns.
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
