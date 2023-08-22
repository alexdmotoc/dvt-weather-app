//
//  WeatherApp_iOSApp.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 22.08.2023.
//

import SwiftUI
import WeatherApp
import CoreLocation

@main
struct WeatherApp_iOSApp: App {
    
    private let weatherViewModel: WeatherViewModel = {
        WeatherViewModel(locationManager: CLLocationManager())
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: weatherViewModel)
        }
    }
}
