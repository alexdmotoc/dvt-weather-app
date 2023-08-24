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
    @State private var mapRegion: MKCoordinateRegion
    
    init(viewModel: MapTabViewModel) {
        self.viewModel = viewModel
        let delta: CLLocationDegrees = 0.2
        if let weather = viewModel.weather.first {
            mapRegion = MKCoordinateRegion(center: weather.weather.location.coordinates.toCLCoordinates, span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta))
        } else {
            mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 46.770439, longitude: 23.591423), span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta))
        }
    }
    
    var body: some View {
        Map(
            coordinateRegion: $mapRegion,
            showsUserLocation: true,
            annotationItems: viewModel.weather.filter({ !$0.weather.isCurrentLocation })
        ) { weather in
            MapAnnotation(coordinate: weather.weather.location.coordinates.toCLCoordinates) {
                Text(weather.weather.location.name)
                    .bold()
                    .padding()
                    .background(Ellipse().fill(Color.red))
                    .foregroundColor(.white)
            }
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
