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
        if viewModel.isLocationPermissionGranted {
            weatherContent
        } else {
            noLocationPermissionView
        }
    }
    
    @ViewBuilder
    var weatherContent: some View {
        let weather = store.weatherInformation.first(where: { $0.isCurrentLocation })
        WeatherView(weatherInfo: .init(
            info: weather ?? viewModel.emptyWeather,
            temperatureType: appSettings.temperatureType,
            lastUpdated: viewModel.lastUpdated,
            onRefresh: {
                Task { await viewModel.getWeather() }
            }
        ))
    }
    
    @ViewBuilder
    var noLocationPermissionView: some View {
        VStack(spacing: 20) {
            Text("locationPermission.title").bold()
            Text("locationPermission.message")
            Link("locationPermission.openSettings", destination: URL(string: UIApplication.openSettingsURLString)!)
        }
        .padding()
    }
}
