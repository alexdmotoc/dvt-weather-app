//
//  MapTab.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 24.08.2023.
//

import SwiftUI
import MapKit

struct MapTab: View {
    
    @ObservedObject private var viewModel: MapTabViewModel
    private let mapRegion: MKCoordinateRegion
    
    init(viewModel: MapTabViewModel) {
        self.viewModel = viewModel
        let delta: CLLocationDegrees = 0.2
        let coordinates: CLLocationCoordinate2D
        if let weather = viewModel.weather.first {
            coordinates = weather.weather.location.coordinates.toCLCoordinates
        } else {
            coordinates = CLLocationCoordinate2D(latitude: 46.770439, longitude: 23.591423)
        }
        mapRegion = MKCoordinateRegion(
            center: coordinates,
            span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
        )
    }
    
    var body: some View {
        Map(
            coordinateRegion: .constant(mapRegion),
            showsUserLocation: true,
            annotationItems: viewModel.weather.filter({ !$0.weather.isCurrentLocation })
        ) { weather in
            MapMarker(coordinate: weather.weather.location.coordinates.toCLCoordinates)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct MapTab_Previews: PreviewProvider {
    static let store = WeatherInformationStore(weatherInformation: [
        .makeMock(name: "mock", isCurrentLocation: false, weatherType: .sunny)
    ])
    
    static var previews: some View {
        MapTab(viewModel: MapTabViewModel(store: store))
    }
}
