//
//  WeatherApp_iOSApp.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 22.08.2023.
//

import SwiftUI

@main
struct WeatherAppiOSApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                viewModel: DIContainer.weatherViewModel,
                favouritesViewModel: DIContainer.favouritesViewModel,
                appSettings: DIContainer.appSettings
            )
        }
    }
}
