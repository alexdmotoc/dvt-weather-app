//
//  PlaceDetailsViewController.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 29.08.2023.
//

import UIKit

class PlaceDetailsViewController: UIViewController {
    
    // MARK: - Private properties
    
    private let viewModel: PlaceDetailsViewModel
    private typealias Section = PlaceDetailsViewModel.Section
    private typealias Item = PlaceDetailsViewModel.Item
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private let columnCount: CGFloat = 3
    private var itemWidth: CGFloat {
        guard let screen = view.window?.windowScene?.screen else { return 0 }
        return screen.bounds.width / columnCount
    }
    
    // MARK: - UI
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        indicator.color = .systemGray
        return indicator
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .clear
        collection.delegate = self
        return collection
    }()
    
    // MARK: - Lifecycle
    
    init(viewModel: PlaceDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.locationName
        view.backgroundColor = .systemGroupedBackground
        configureViewHierarchy()
        configureDataSource()
        bindViewModel()
        viewModel.loadDetails()
    }
    
    // MARK: - Private methods
    
    private func configureViewHierarchy() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            view.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor)
        ])
        
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func configureDataSource() {
        let config = UICollectionView.CellRegistration<PlaceCell, Item> {
            [weak self] cell, indexPath, item in
            guard let self else { return }
            Task {
                do {
                    let data = try await self.viewModel.photoFetcher.fetchPhoto(
                        reference: item.reference,
                        maxWidth: Int(self.itemWidth),
                        maxHeight: nil
                    )
                    DispatchQueue.main.async {
                        cell.imageView.image = UIImage(data: data)
                    }
                } catch {
                    self.displayError(error)
                }
            }
        }
        dataSource = .init(collectionView: collectionView, cellProvider: {
            collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: config, for: indexPath, item: item)
        })
    }
    
    private func bindViewModel() {
        viewModel.didEncounterError = displayError
        viewModel.didLoadDetails = populateCollectionView
    }
    
    private func populateCollectionView(_ details: [Item]) {
        activityIndicator.stopAnimating()
        var snapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        snapshot.append(details)
        dataSource.apply(snapshot, to: .main, animatingDifferences: true)
        if details.isEmpty { displayError(Error.noPhotos) }
    }
}

// MARK: - UICollectionViewDelegate

extension PlaceDetailsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        let viewController = ZoomableImageViewController(photo: item, photoFetcher: viewModel.photoFetcher)
        let nav = UINavigationController(rootViewController: viewController)
        present(nav, animated: true)
    }
}

// MARK: - Utils

private extension PlaceDetailsViewController {
    func makeCollectionViewLayout() -> UICollectionViewLayout {
        let spacing: CGFloat = 3
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / columnCount),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1.0 / columnCount)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: Int(columnCount)
        )
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(
            top: spacing,
            leading: spacing,
            bottom: spacing,
            trailing: spacing
        )
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    enum Error: Swift.Error, LocalizedError {
        case noPhotos
        
        var errorDescription: String? {
            switch self {
            case .noPhotos:
                return NSLocalizedString("noPhotos.error.message", comment: "")
            }
        }
    }
}
