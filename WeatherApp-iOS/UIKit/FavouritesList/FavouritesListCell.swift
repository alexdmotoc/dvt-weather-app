//
//  FavouritesListCell.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 24.08.2023.
//

import UIKit

class FavouritesListCell: UICollectionViewCell {
    
    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private(set) lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private(set) lazy var currentTemperatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private(set) lazy var minTemperatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private(set) lazy var maxTemperatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var titlesStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var minMaxStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [minTemperatureLabel, maxTemperatureLabel])
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var temperatureStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [currentTemperatureLabel, minMaxStack])
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titlesStack, temperatureStack])
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        contentView.addSubview(mainStack)
        let spacing: CGFloat = 12
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: spacing),
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: spacing),
            contentView.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor, constant: spacing),
            contentView.bottomAnchor.constraint(equalTo: mainStack.bottomAnchor, constant: spacing)
        ])
    }
}
