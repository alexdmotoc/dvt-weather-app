//
//  UIView+Utils.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 30.08.2023.
//

import UIKit

extension UIView {
    func pin(subview: UIView) {
        addSubview(subview)
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: leadingAnchor),
            subview.topAnchor.constraint(equalTo: topAnchor),
            trailingAnchor.constraint(equalTo: subview.trailingAnchor),
            bottomAnchor.constraint(equalTo: subview.bottomAnchor)
        ])
    }
}
