//
//  WeatherViewModelTests.swift
//  WeatherApp-iOSTests
//
//  Created by Alex Motoc on 22.08.2023.
//

import XCTest
import CoreLocation
import WeatherApp
@testable import WeatherApp_iOS

@MainActor
final class WeatherViewModelTests: XCTestCase {
    
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
    
    func test_getWeather_callsRepository() async {
        let (_, useCase, sut) = makeSUT()
        
        await sut.getWeather()
        
        XCTAssertEqual(useCase.getWeatherCallCount, 1)
    }
    
    func test_getWeatherTwice_callsRepositoryTwice() async {
        let (_, useCase, sut) = makeSUT()
        
        await sut.getWeather()
        await sut.getWeather()
        
        XCTAssertEqual(useCase.getWeatherCallCount, 2)
    }
    
    // MARK: - Helpers
    
    @MainActor
    private func makeSUT(
        isAuthorized: Bool = false,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (manager: MockCLLocationManager, useCase: MockGetWeatherUseCase, sut: WeatherViewModel) {
        
        let manager = MockCLLocationManager()
        manager.stubbedIsAuthorized = isAuthorized
        let useCase = MockGetWeatherUseCase()
        let locationManager = LocationManager(manager: manager)
        let sut = WeatherViewModel(locationManager: locationManager, useCase: useCase)
        
        checkIsDeallocated(sut: manager, file: file, line: line)
        checkIsDeallocated(sut: locationManager, file: file, line: line)
        checkIsDeallocated(sut: useCase, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (manager, useCase, sut)
    }
}
