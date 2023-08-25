//
//  FavouritesListHeader.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 25.08.2023.
//

import UIKit

class FavouritesListHeader: UICollectionReusableView {
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.text = NSLocalizedString("longPressToDelete.title", comment: "")
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            trailingAnchor.constraint(equalTo: label.trailingAnchor),
            bottomAnchor.constraint(equalTo: label.bottomAnchor)
        ])
    }
}
