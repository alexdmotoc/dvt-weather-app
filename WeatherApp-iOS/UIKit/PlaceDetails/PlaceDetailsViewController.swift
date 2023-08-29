//
//  PlaceDetailsViewController.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 29.08.2023.
//

import UIKit

class PlaceDetailsViewController: UIViewController {
    
    private let viewModel: PlaceDetailsViewModel
    
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
    }
}
