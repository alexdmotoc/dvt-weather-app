//
//  LocationManagerTests.swift
//  WeatherApp-iOSTests
//
//  Created by Alex Motoc on 23.08.2023.
//

import XCTest
import CoreLocation
@testable import WeatherApp_iOS

final class LocationManagerTests: XCTestCase {
    
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
        XCTAssertEqual(manager.distanceFilter, 5_000)
        XCTAssertEqual(manager.delegate as? LocationManager, sut)
    }
    
    func test_authorizationChanged_callsNotificationClosure() {
        let (manager, sut) = makeSUT()
        var didNotify = false
        XCTAssertEqual(sut.isAuthorized, false)
        
        sut.didChangeAuthorizationStatus = { isAuthorized in
            XCTAssertTrue(isAuthorized)
            didNotify = true
        }
        
        manager.stubbedIsAuthorized = true
        manager.delegate!.locationManagerDidChangeAuthorization?(manager)
        
        XCTAssertTrue(didNotify)
    }
    
    func test_locationChanged_callsNotificationClosure() {
        let (manager, sut) = makeSUT()
        var didNotify = false
        let mockLocation = makeLocation()
        XCTAssertNil(sut.currentLocation)
        
        sut.didChangeLocation = { location in
            XCTAssertEqual(location, mockLocation)
            didNotify = true
        }
        
        manager.delegate!.locationManager?(manager, didUpdateLocations: [mockLocation])
        
        XCTAssertTrue(didNotify)
    }
    
    func test_locationChanged_deliversMostRecentLocationFromDelegate() {
        let (manager, sut) = makeSUT()
        let mockLocationOld = makeLocation(timeStamp: .distantPast)
        let mockLocationNew = makeLocation()
        
        manager.stubbedCurrentLocation = mockLocationOld
        manager.delegate!.locationManager?(manager, didUpdateLocations: [mockLocationNew])
        
        XCTAssertEqual(sut.currentLocation, mockLocationNew)
    }
    
    func test_locationChanged_deliversMostRecentLocationFromManagerLocation() {
        let (manager, sut) = makeSUT()
        let mockLocationOld = makeLocation(timeStamp: .distantPast)
        let mockLocationNew = makeLocation()
        
        manager.stubbedCurrentLocation = mockLocationNew
        manager.delegate!.locationManager?(manager, didUpdateLocations: [mockLocationOld])
        
        XCTAssertEqual(sut.currentLocation, mockLocationNew)
    }
    
    func test_startsUpdatingLocations_whenLocationPermissionIsGranted() {
        let (manager, sut) = makeSUT()
        XCTAssertEqual(manager.startCallCount, 0)

        manager.stubbedIsAuthorized = true
        manager.delegate!.locationManagerDidChangeAuthorization?(manager)

        XCTAssertEqual(manager.startCallCount, 1)
        XCTAssertEqual(sut.isAuthorized, true)
    }

    func test_doesNotStartUpdatingLocations_whenLocationPermissionIsDenied() {
        let (manager, sut) = makeSUT()
        XCTAssertEqual(manager.startCallCount, 0)

        manager.delegate!.locationManagerDidChangeAuthorization?(manager)

        XCTAssertEqual(manager.startCallCount, 0)
        XCTAssertEqual(sut.isAuthorized, false)
    }
    
    func test_requestLocationPermission_doesNothingIfPermissionAlreadyGranted() {
        let (manager, sut) = makeSUT(isAuthorized: true)

        sut.requestWhenInUseAuthorization()

        XCTAssertEqual(manager.requestCallCount, 0)
    }

    func test_requestLocationPermission_requestsPermissionIfNotAlreadyGranted() {
        let (manager, sut) = makeSUT(isAuthorized: false)

        sut.requestWhenInUseAuthorization()

        XCTAssertEqual(manager.requestCallCount, 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(isAuthorized: Bool = false, file: StaticString = #filePath, line: UInt = #line) -> (manager: MockCLLocationManager, sut: LocationManager) {
        let manager = MockCLLocationManager(isAuthorized: isAuthorized)
        let sut = LocationManager(manager: manager)
        checkIsDeallocated(sut: manager)
        checkIsDeallocated(sut: sut)
        return (manager, sut)
    }
}
