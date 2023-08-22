//
//  WeatherApp_iOSTests.swift
//  WeatherApp-iOSTests
//
//  Created by Alex Motoc on 22.08.2023.
//

import XCTest
import CoreLocation
@testable import WeatherApp_iOS

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
    
    func test_requestLocationPermission_doesNothingIfPermissionAlreadyGranted() {
        let (manager, sut) = makeSUT(isAuthorized: true)
        
        sut.requestLocationPermission()
        
        XCTAssertEqual(manager.requestCallCount, 0)
    }
    
    func test_requestLocationPermission_requestsPermissionIfNotAlreadyGranted() {
        let (manager, sut) = makeSUT(isAuthorized: false)
        
        sut.requestLocationPermission()
        
        XCTAssertEqual(manager.requestCallCount, 1)
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
}
