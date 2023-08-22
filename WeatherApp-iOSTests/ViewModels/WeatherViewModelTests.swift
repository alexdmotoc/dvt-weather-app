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
    
    // MARK: - Private properties
    
    private static let locationDistanceFilter: CLLocationDistance = 10_000 // 10 km
    private let locationManager: CLLocationManager
    
    // MARK: - Public properties
    
    @Published private(set) var isLocationPermissionGranted: Bool
    
    // MARK: - Lifecycle
    
    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
        self.isLocationPermissionGranted = locationManager.isAuthorized
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = Self.locationDistanceFilter
        
        if locationManager.isAuthorized {
            locationManager.startUpdatingLocation()
        }
    }
}

extension WeatherViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        isLocationPermissionGranted = manager.isAuthorized
    }
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
    
    func test_locationPermission_isInitializedWithCurrentManagerValue() {
        let (_, sut) = makeSUT()
        XCTAssertEqual(sut.isLocationPermissionGranted, false)
        
        let (_, sut2) = makeSUT(isAuthorized: true)
        XCTAssertEqual(sut2.isLocationPermissionGranted, true)
    }
    
    func test_locationPermission_isUpdatedWhenDelegateUpdatesPermissionStatus() {
        let (manager, sut) = makeSUT()
        XCTAssertEqual(sut.isLocationPermissionGranted, false)
        
        manager.stubbedIsAuthorized = true
        manager.delegate?.locationManagerDidChangeAuthorization?(manager)
        
        XCTAssertEqual(sut.isLocationPermissionGranted, true)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        isAuthorized: Bool = false,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (manager: MockLocationManager, sut: WeatherViewModel) {
        
        let manager = MockLocationManager()
        manager.stubbedIsAuthorized = isAuthorized
        let sut = WeatherViewModel(locationManager: manager)
        
        checkIsDeallocated(sut: manager, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (manager, sut)
    }
    
    private class MockLocationManager: CLLocationManager {
        
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
}
