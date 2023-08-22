//
//  ContentView.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 22.08.2023.
//

import SwiftUI

struct ContentView: View {
    
    let viewModel: WeatherViewModel
    
    var body: some View {
        
        if viewModel.isLocationPermissionGranted {
            Text("permission granted")
        } else {
            Text("NO PERMISSION")
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            viewModel: WeatherViewModel(
                locationManager: MockLocationManager(isAuthorized: true)
            )
        )
    }
}
