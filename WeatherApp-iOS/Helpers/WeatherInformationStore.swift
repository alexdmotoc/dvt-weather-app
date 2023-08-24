//
//  WeatherInformationStore.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 23.08.2023.
//

import Foundation
import WeatherApp

struct IdentifiableWeatherInformation: Identifiable {
    let id = UUID()
    let weather: WeatherInformation
}

class WeatherInformationStore: ObservableObject {
    @Published var weatherInformation: [WeatherInformation] = [] {
        didSet {
            identifiableWeatherInformation = weatherInformation.map(IdentifiableWeatherInformation.init)
        }
    }
    
    @Published private(set) var identifiableWeatherInformation: [IdentifiableWeatherInformation] = []
    
    init(weatherInformation: [WeatherInformation] = []) {
        self.weatherInformation = weatherInformation
        self.identifiableWeatherInformation = weatherInformation.map(IdentifiableWeatherInformation.init)
    }
}
