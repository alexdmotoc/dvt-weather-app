//
//  WeatherApp_iOSTests.swift
//  WeatherApp-iOSTests
//
//  Created by Alex Motoc on 22.08.2023.
//

import XCTest
import CoreLocation
@testable import WeatherApp_iOS

final class WeatherViewModel: NSObject, ObservableObject {
    
    private static let locationDistanceFilter: CLLocationDistance = 10_000 // 10 km
    private var locationManager: LocationManager
    
    init(locationManager: LocationManager) {
        self.locationManager = locationManager
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = Self.locationDistanceFilter
        
        if locationManager.isAuthorized {
            locationManager.startUpdatingLocation()
        }
    }
}

extension WeatherViewModel: CLLocationManagerDelegate {
    
}

final class WeatherApp_iOSTests: XCTestCase {
    
    func test_init_onNonAuthorizedDoesntCallStartUpdatingLocation() {
        let (manager, _) = makeSUT()
        
        XCTAssertEqual(manager.startCallCount, 0)
    }
    
    func test_init_onAuthorizedCallsStartUpdatingLocation() {
        let (manager, _) = makeSUT(isAuthorized: true)
        
        XCTAssertEqual(manager.startCallCount, 1)
    }
    
    func test_init_setsUpLocationManagerCorrectly() {
        let (manager, sut) = makeSUT()
        
        XCTAssertEqual(manager.desiredAccuracy, kCLLocationAccuracyBest)
        XCTAssertEqual(manager.distanceFilter, 10_000)
        XCTAssertEqual(manager.delegate as? WeatherViewModel, sut)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        isAuthorized: Bool = false,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (manager: MockLocationManager, sut: WeatherViewModel) {
        
        let manager = MockLocationManager()
        manager.isAuthorized = isAuthorized
        let sut = WeatherViewModel(locationManager: manager)
        
        checkIsDeallocated(sut: manager, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (manager, sut)
    }
    
    private class MockLocationManager: LocationManager {
        var location: CLLocation?
        weak var delegate: CLLocationManagerDelegate?
        var distanceFilter: CLLocationDistance = kCLDistanceFilterNone
        var desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest
        var isAuthorized: Bool = false
        
        var requestCallCount = 0
        var startCallCount = 0
        
        func requestWhenInUseAuthorization() {
            requestCallCount += 1
        }
        
        func startUpdatingLocation() {
            startCallCount += 1
        }
    }
}
