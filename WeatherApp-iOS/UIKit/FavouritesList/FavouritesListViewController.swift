//
//  FavouritesListViewController.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 24.08.2023.
//

import UIKit

class FavouritesListViewController: UIViewController {
    
    private let viewModel: FavouritesListViewModel
    
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
        
        let label = UILabel()
        label.text = "some dummy text"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
    }

}
