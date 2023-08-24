//
//  MapTabViewModel.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 24.08.2023.
//

import Foundation
import WeatherApp
import Combine

final class MapTabViewModel: ObservableObject {
    struct IdentifiableWeatherInformation: Identifiable {
        let id = UUID()
        let weather: WeatherInformation
    }
    
    @Published private(set) var weather: [IdentifiableWeatherInformation]
    private var cancellable: AnyCancellable?
    
    init(store: WeatherInformationStore) {
        weather = store.weatherInformation.map(IdentifiableWeatherInformation.init)
        cancellable = store.$weatherInformation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] weatherInfo in
                self?.weather = weatherInfo.map(IdentifiableWeatherInformation.init)
            }
    }
}
