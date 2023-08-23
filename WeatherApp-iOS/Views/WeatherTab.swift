//
//  WeatherTab.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 23.08.2023.
//

import SwiftUI

struct WeatherTab: View {
    
    @ObservedObject var viewModel: WeatherViewModel
    @ObservedObject var store: WeatherInformationStore
    @ObservedObject var appSettings: AppSettings
    
    var body: some View {
        Group {
            if viewModel.isLocationPermissionGranted {
                if let currentWeather = store
                    .weatherInformation
                    .first(where: { $0.isCurrentLocation })
                {
                    WeatherView(weatherInfo: .init(
                        info: currentWeather,
                        temperatureType: appSettings.temperatureType
                    ))
                } else {
                    Text("noWeather.message")
                }
            } else {
                Text("NO PERMISSION")
            }
        }
    }
}
