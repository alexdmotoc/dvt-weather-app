//
//  WeatherInformationStore.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 23.08.2023.
//

import Foundation
import WeatherApp

@MainActor
class WeatherInformationStore: ObservableObject {
    @Published var weatherInformation: [WeatherInformation]
    
    init(weatherInformation: [WeatherInformation] = []) {
        self.weatherInformation = weatherInformation
    }
}
