//
//  MockLocationManager.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 22.08.2023.
//

import Foundation
import CoreLocation

class MockLocationManager: CLLocationManager {
    
    convenience init(isAuthorized: Bool) {
        self.init()
        stubbedIsAuthorized = isAuthorized
    }
    
    var stubbedIsAuthorized: Bool = false
    override var authorizationStatus: CLAuthorizationStatus {
        stubbedIsAuthorized ? .authorizedWhenInUse : .denied
    }
    
    var requestCallCount = 0
    var startCallCount = 0
    
    override func requestWhenInUseAuthorization() {
        requestCallCount += 1
    }
    
    override func startUpdatingLocation() {
        startCallCount += 1
    }
}
