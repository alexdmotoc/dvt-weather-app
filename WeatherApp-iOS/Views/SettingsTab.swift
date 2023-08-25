//
//  SettingsTab.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 23.08.2023.
//

import SwiftUI

struct SettingsTab: View {
    
    @ObservedObject var appSettings: AppSettings
    
    var body: some View {
        VStack {
            Text("selectTemperature.title").bold()
            Picker("Temperature", selection: $appSettings.temperatureType) {
                ForEach(TemperatureType.allCases, id: \.self) { temp in
                    Text(temp.titleLocalizationKey).tag(temp)
                }
            }
            .pickerStyle(.segmented)
            Spacer()
        }
        .padding()
    }
}

// MARK: - TemperatureType + Utils

private extension TemperatureType {
    var titleLocalizationKey: LocalizedStringKey {
        switch self {
        case .celsius: return "celsius.title"
        case .fahrenheit: return "fahrenheit.title"
        }
    }
}

// MARK: - Previews

struct SettingsTab_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTab(appSettings: AppSettings())
    }
}
