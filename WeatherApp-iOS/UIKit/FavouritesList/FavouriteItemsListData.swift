//
//  FavouriteItemsListData.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 24.08.2023.
//

import Foundation

enum FavouriteItemsListData {
    enum Section {
        case main
    }
    
    struct Item: Hashable {
        let id = UUID()
        let locationName: String
        let isCurrentLocation: Bool
        let weatherTypeTitleKey: String
        let backgroundColorName: String
        let currentTemperature: Int
        let minTemperature: Int
        let maxTemperature: Int
    }
}
