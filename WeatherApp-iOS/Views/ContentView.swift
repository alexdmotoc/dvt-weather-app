//
//  ContentView.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 22.08.2023.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        Group {
            if viewModel.isLocationPermissionGranted {
                Text("permission granted")
            } else {
                Text("NO PERMISSION")
            }
        }.onAppear {
            viewModel.requestLocationPermission()
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    
    static var useCase: MockGetWeatherUseCase {
        let useCase = MockGetWeatherUseCase()
        useCase.stub = .init(
            cache: [],
            result: [
                .makeMock(name: "Mock curr location", isCurrentLocation: true, weatherType: .sunny),
                .makeMock(name: "Mock fav location 1", isCurrentLocation: false, weatherType: .cloudy),
                .makeMock(name: "Mock fav location 2", isCurrentLocation: false, weatherType: .rainy)
            ],
            error: nil
        )
        return useCase
    }
    
    static var previews: some View {
        ContentView(
            viewModel: WeatherViewModel(
                locationManager: LocationManager(manager: MockCLLocationManager(isAuthorized: true)),
                useCase: useCase
            )
        )
    }
}
