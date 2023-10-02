//
//  ZoomableImageViewController.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 30.08.2023.
//

import UIKit
import WeatherApp

class ZoomableImageViewController: UIViewController {
    
    // MARK: - Private properties
    
    private let photo: PlaceDetailsViewModel.Item
    private let photoFetcher: PlacePhotoFetcher
    
    // MARK: - UI
    
    private var imageViewBottomConstraint: NSLayoutConstraint!
    private var imageViewLeadingConstraint: NSLayoutConstraint!
    private var imageViewTopConstraint: NSLayoutConstraint!
    private var imageViewTrailingConstraint: NSLayoutConstraint!
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        indicator.color = .systemGray
        return indicator
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.delegate = self
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.addSubview(imageView)
        imageViewTopConstraint = imageView.topAnchor.constraint(equalTo: scroll.topAnchor)
        imageViewLeadingConstraint = imageView.leadingAnchor.constraint(equalTo: scroll.leadingAnchor)
        imageViewBottomConstraint = scroll.bottomAnchor.constraint(equalTo: imageView.bottomAnchor)
        imageViewTrailingConstraint = scroll.trailingAnchor.constraint(equalTo: imageView.trailingAnchor)
        NSLayoutConstraint.activate([
            imageViewTopConstraint,
            imageViewLeadingConstraint,
            imageViewBottomConstraint,
            imageViewTrailingConstraint
        ])
        return scroll
    }()
    
    // MARK: - Lifecycle
    
    init(
        photo: PlaceDetailsViewModel.Item,
        photoFetcher: PlacePhotoFetcher
    ) {
        self.photo = photo
        self.photoFetcher = photoFetcher
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        configureViewHierarchy()
        loadPhoto()
    }
    
    // MARK: - Private methods
    
    private func configureViewHierarchy() {
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        view.pin(subview: scrollView)
        
        let action = UIAction { [weak self] _ in self?.dismiss(animated: true) }
        let item = UIBarButtonItem(systemItem: .close, primaryAction: action)
        navigationItem.leftBarButtonItem = item
    }
    
    private func loadPhoto() {
        Task {
            do {
                let data = try await photoFetcher.fetchPhoto(
                    reference: photo.reference,
                    maxWidth: photo.width,
                    maxHeight: photo.height
                )
                DispatchQueue.main.async {
                    self.handleDidLoadImageData(data)
                }
            } catch {
                displayError(error)
            }
        }
    }
    
    private func handleDidLoadImageData(_ data: Data) {
        guard let image = UIImage(data: data) else { return }
        imageView.image = image
        updateZoomScaleForSize(scrollView.bounds.size, image: image)
        activityIndicator.stopAnimating()
        view.layoutIfNeeded()
        updateConstraintsForSize(scrollView.bounds.size)
    }
    
    private func updateZoomScaleForSize(_ size: CGSize, image: UIImage) {
        let widthScale = size.width / image.size.width
        let heightScale = size.height / image.size.height
        let minScale = min(widthScale, heightScale)
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }
}

// MARK: - UIScrollViewDelegate

extension ZoomableImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(scrollView.bounds.size)
    }
    
    private func updateConstraintsForSize(_ size: CGSize) {
        let yOffset = max(0, (size.height - imageView.frame.size.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        
        let xOffset = max(0, (size.width - imageView.frame.size.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
    }
}
