//
//  WeatherView.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 23.08.2023.
//

import SwiftUI
import WeatherApp

struct WeatherView: View {
    
    let weatherInfo: WeatherInfoViewModel
    
    var body: some View {
        ZStack {
            Color(weatherInfo.backgroundColorName)
                .edgesIgnoringSafeArea(.all)
            Text(weatherInfo.info.location.name) + Text("\(weatherInfo.currentTemperature)º")
        }
    }
}


struct WeatherView_Previews: PreviewProvider {
    
    static var previews: some View {
        WeatherView(weatherInfo: .init(info: .makeMock(name: "some weather", isCurrentLocation: true, weatherType: .sunny), temperatureType: .celsius))
    }
    
}
