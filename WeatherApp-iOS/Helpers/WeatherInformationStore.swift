//
//  WeatherInformationStore.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 23.08.2023.
//

import Foundation
import WeatherApp

class WeatherInformationStore: ObservableObject {
    @Published var weatherInformation: [WeatherInformation] = []
}
