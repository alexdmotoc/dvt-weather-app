//
//  WeatherApp_iOSTests.swift
//  WeatherApp-iOSTests
//
//  Created by Alex Motoc on 22.08.2023.
//

import XCTest
import CoreLocation
import WeatherApp
@testable import WeatherApp_iOS

final class WeatherApp_iOSTests: XCTestCase {
    
    func test_init_onNonAuthorizedDoesntCallStartUpdatingLocation() {
        let (manager, _, _) = makeSUT()
        
        XCTAssertEqual(manager.startCallCount, 0)
    }
    
    func test_init_onAuthorizedCallsStartUpdatingLocation() {
        let (manager, _, _) = makeSUT(isAuthorized: true)
        
        XCTAssertEqual(manager.startCallCount, 1)
    }
    
    func test_init_setsUpLocationManagerCorrectly() {
        let (manager, _, sut) = makeSUT()
        
        XCTAssertEqual(manager.desiredAccuracy, kCLLocationAccuracyBest)
        XCTAssertEqual(manager.distanceFilter, 10_000)
        XCTAssertEqual(manager.delegate as? WeatherViewModel, sut)
    }
    
    func test_locationPermission_isInitializedWithCurrentManagerValue() {
        let (_, _, sut) = makeSUT()
        XCTAssertEqual(sut.isLocationPermissionGranted, false)
        
        let (_, _, sut2) = makeSUT(isAuthorized: true)
        XCTAssertEqual(sut2.isLocationPermissionGranted, true)
    }
    
    func test_locationPermission_isUpdatedWhenDelegateUpdatesPermissionStatus() {
        let (manager, _, sut) = makeSUT()
        XCTAssertEqual(sut.isLocationPermissionGranted, false)
        
        manager.stubbedIsAuthorized = true
        manager.delegate!.locationManagerDidChangeAuthorization?(manager)
        
        XCTAssertEqual(sut.isLocationPermissionGranted, true)
    }
    
    func test_requestLocationPermission_doesNothingIfPermissionAlreadyGranted() {
        let (manager, _, sut) = makeSUT(isAuthorized: true)
        
        sut.requestLocationPermission()
        
        XCTAssertEqual(manager.requestCallCount, 0)
    }
    
    func test_requestLocationPermission_requestsPermissionIfNotAlreadyGranted() {
        let (manager, _, sut) = makeSUT(isAuthorized: false)
        
        sut.requestLocationPermission()
        
        XCTAssertEqual(manager.requestCallCount, 1)
    }
    
    func test_startsUpdatingLocations_whenLocationPermissionIsGranted() {
        let (manager, _, sut) = makeSUT()
        XCTAssertEqual(manager.startCallCount, 0)
        
        manager.stubbedIsAuthorized = true
        manager.delegate!.locationManagerDidChangeAuthorization?(manager)
        
        XCTAssertEqual(manager.startCallCount, 1)
        XCTAssertEqual(sut.isLocationPermissionGranted, true)
    }
    
    func test_doesNotStartUpdatingLocations_whenLocationPermissionIsDenied() {
        let (manager, _, sut) = makeSUT()
        XCTAssertEqual(manager.startCallCount, 0)
        
        manager.delegate!.locationManagerDidChangeAuthorization?(manager)
        
        XCTAssertEqual(manager.startCallCount, 0)
        XCTAssertEqual(sut.isLocationPermissionGranted, false)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        isAuthorized: Bool = false,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (manager: MockLocationManager, repo: WeatherRepositorySpy, sut: WeatherViewModel) {
        
        let manager = MockLocationManager()
        manager.stubbedIsAuthorized = isAuthorized
        let repo = WeatherRepositorySpy(getWeatherResult: makeWeatherInformationArray(), addFavouriteResult: makeWeatherInformationWithForecast())
        let sut = WeatherViewModel(locationManager: manager, weatherRepository: repo)
        
        checkIsDeallocated(sut: manager, file: file, line: line)
        checkIsDeallocated(sut: repo, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (manager, repo, sut)
    }
    
    private class WeatherRepositorySpy: WeatherRepository {
        
        var getWeatherResult: [WeatherInformation]
        var addFavouriteResult: WeatherInformation
        
        init(getWeatherResult: [WeatherInformation], addFavouriteResult: WeatherInformation) {
            self.getWeatherResult = getWeatherResult
            self.addFavouriteResult = addFavouriteResult
        }
        
        var getWeatherCallCount = 0
        var addFavouriteCallCount = 0
        
        func getWeather(cacheHandler: ([WeatherInformation]) -> Void) async throws -> [WeatherInformation] {
            getWeatherCallCount += 1
            return getWeatherResult
        }
        
        func addFavouriteLocation(coordinates: Coordinates) async throws -> WeatherInformation {
            addFavouriteCallCount += 1
            return addFavouriteResult
        }
    }
}
