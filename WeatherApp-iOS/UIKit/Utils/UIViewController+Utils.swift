//
//  UIViewController+Utils.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 29.08.2023.
//

import UIKit

extension UIViewController {
    func displayError(_ error: Swift.Error) {
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
}
