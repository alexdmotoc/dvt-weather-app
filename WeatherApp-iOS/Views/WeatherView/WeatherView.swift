//
//  WeatherView.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 23.08.2023.
//

import SwiftUI

struct WeatherView: View {
    
    let weatherInfo: WeatherInfoViewModel
    
    var body: some View {
        ZStack {
            Color(weatherInfo.backgroundColorName)
                .edgesIgnoringSafeArea(.all)
            
            GeometryReader { geom in
                VStack {
                    makeTopWeatherInfo(geometry: geom)
                    HStack {
                        makeTemperatureView(type: .min)
                        Spacer()
                        makeTemperatureView(type: .current)
                        Spacer()
                        makeTemperatureView(type: .max)
                    }
                    .padding(.horizontal)
                    Color.white.frame(height: 1)
                }
            }
        }
    }
    
    @ViewBuilder
    func makeTopWeatherInfo(geometry geom: GeometryProxy) -> some View {
        ZStack {
            Image(weatherInfo.backgroundImageName)
                .resizable()
                .edgesIgnoringSafeArea(.top)
                .frame(height: geom.size.height * 0.4)
            VStack {
                Text(weatherInfo.info.location.name).font(.system(size: 24, weight: .light))
                Text(weatherInfo.formattedTemperature(type: .current)).font(.system(size: 80))
                Text(LocalizedStringKey(weatherInfo.formattedWeatherTitle)).font(.system(size: 30)).bold()
            }
            .foregroundColor(.white)
            .offset(y: -70)
        }
    }
    
    func makeTemperatureView(type: WeatherInfoViewModel.TemperatureValue) -> some View {
        VStack {
            Text(weatherInfo.formattedTemperature(type: type))
                .font(.system(size: 18, weight: .medium))
            Text(type.title)
                .font(.system(size: 16, weight: .light))
        }
        .foregroundColor(.white)
    }
}


struct WeatherView_Previews: PreviewProvider {
    
    static var previews: some View {
        WeatherView(weatherInfo: .init(info: .makeMock(name: "some weather", isCurrentLocation: true, weatherType: .sunny), temperatureType: .celsius))
        WeatherView(weatherInfo: .init(info: .emptyWeather, temperatureType: .celsius))
    }
    
}
