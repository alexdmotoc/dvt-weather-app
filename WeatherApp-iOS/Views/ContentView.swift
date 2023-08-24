//
//  ContentView.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 22.08.2023.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject private var viewModel: WeatherViewModel
    @ObservedObject private var store: WeatherInformationStore
    @ObservedObject private var appSettings: AppSettings
    private let favouritesViewModel: FavouritesListViewModel
    
    @State private var tabSelection: Int = 1
    
    init(viewModel: WeatherViewModel, favouritesViewModel: FavouritesListViewModel, appSettings: AppSettings) {
        self.viewModel = viewModel
        self.favouritesViewModel = favouritesViewModel
        self.appSettings = appSettings
        self.store = viewModel.weatherStore
    }
    
    var body: some View {
        TabView(selection: $tabSelection) {
            
            MapTab(viewModel: MapTabViewModel(store: viewModel.weatherStore))
                .tabItem {
                    Label("map.title", systemImage: "map")
                }
                .tag(0)
            
            WeatherTab(
                viewModel: viewModel,
                store: store,
                appSettings: appSettings
            )
            .tabItem {
                Label("weather.title", systemImage: "cloud.sun")
            }
            .tag(1)
            
            FavouritesTab(viewModel: favouritesViewModel)
                .edgesIgnoringSafeArea(.top)
                .tabItem {
                    Label("favourites.title", systemImage: "heart")
                }
            
            SettingsTab(appSettings: appSettings)
                .tabItem {
                    Label("settings.title", systemImage: "gear")
                }
                .tag(3)
        }
        .onAppear {
            // add tabbar background
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            
            viewModel.requestLocationPermission()
        }
        .task {
            await viewModel.getWeather()
        }
        .alert(
            "error.title",
            isPresented: $viewModel.isErrorShown,
            actions: {
                Button("dismiss.title", role: .cancel, action: {})
            }, message: {
                Text(viewModel.errorMessage ?? "")
            }
        )
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    
    static let useCase: MockGetWeatherUseCase = {
        let useCase = MockGetWeatherUseCase()
        useCase.stub = .init(
            cache: [.makeMock(name: "Mock curr location", isCurrentLocation: true, weatherType: .sunny)],
            result: [
                .makeMock(name: "Mock curr location", isCurrentLocation: true, weatherType: .sunny),
                .makeMock(name: "Mock fav location 1", isCurrentLocation: false, weatherType: .cloudy),
                .makeMock(name: "Mock fav location 2", isCurrentLocation: false, weatherType: .rainy)
            ],
            error: nil
        )
        return useCase
    }()
    
    static var previews: some View {
        ContentView(
            viewModel: WeatherViewModel(
                locationManager: LocationManager(manager: MockCLLocationManager(isAuthorized: true)),
                useCase: useCase,
                weatherStore: WeatherInformationStore()
            ),
            favouritesViewModel: FavouritesListViewModel(store: WeatherInformationStore(), useCase: MockFavouriteLocationUseCase()),
            appSettings: AppSettings()
        )
    }
}
