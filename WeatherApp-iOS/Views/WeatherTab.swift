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
            PageView(pages: makeWeatherPages(isLocationPermissionGranted: true))
                .id(UUID())
                .edgesIgnoringSafeArea(.top)
        } else {
            let weatherPages = makeWeatherPages(isLocationPermissionGranted: false).map { AnyView($0) }
            let pages: [AnyView] = [AnyView(noLocationPermissionView)] + weatherPages
            PageView(pages: pages)
                .id(UUID())
                .edgesIgnoringSafeArea(.top)
        }
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
    
    func makeWeatherPages(isLocationPermissionGranted: Bool) -> [WeatherView] {
        var array = store.weatherInformation
        if array.isEmpty && isLocationPermissionGranted {
            array = [viewModel.emptyWeather]
        }
        return array.map {
            WeatherView(weatherInfo: .init(
                info: $0,
                temperatureType: appSettings.temperatureType,
                lastUpdated: viewModel.lastUpdated,
                onRefresh: {
                    Task { await viewModel.getWeather() }
                })
            )
        }
    }
}
