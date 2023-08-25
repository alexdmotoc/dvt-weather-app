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
    
    func test_getWeather_callsUseCase() async {
        let (_, useCase, sut) = makeSUT()
        
        await sut.getWeather()
        
        XCTAssertEqual(useCase.getWeatherCallCount, 1)
    }
    
    func test_getWeatherTwice_callsUseCaseTwice() async {
        let (_, useCase, sut) = makeSUT()
        
        await sut.getWeather()
        await sut.getWeather()
        
        XCTAssertEqual(useCase.getWeatherCallCount, 2)
    }
    
    func test_getWeather_onErrorUpdatesEncounteredErrorMessage() async {
        let (_, useCase, sut) = makeSUT()
        let mockError = makeNSError()
        XCTAssertFalse(sut.isErrorShown)
        XCTAssertNil(sut.errorMessage)
        
        useCase.stub = .init(cache: [], result: [], error: mockError)
        await sut.getWeather()
        
        XCTAssertTrue(sut.isErrorShown)
        XCTAssertEqual(sut.errorMessage, mockError.localizedDescription)
    }
    
    func test_getWeather_onSuccessUpdatesWeatherStore() async {
        let (_, useCase, sut) = makeSUT()
        let mockResults = makeWeatherInformationArray()
        
        useCase.stub = .init(cache: [], result: mockResults, error: nil)
        await sut.getWeather()
        
        XCTAssertEqual(sut.weatherStore.weatherInformation, mockResults)
    }
    
    func test_onLocationChange_callsGetWeather() {
        let (manager, useCase, sut) = makeSUT()
        XCTAssertFalse(sut.isLocationPermissionGranted) // silence unused warning; keeps reference to sut
        XCTAssertEqual(useCase.getWeatherCallCount, 0)
        
        let exp = expectation(description: "call get weather")
        useCase.didCallGetWeather = {
            // need to fulfill on main thread because in this case the work is dispatched
            // to a background thread which didn't finish so our SUT is not deallocated
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { exp.fulfill() }
        }
        
        manager.delegate!.locationManager?(manager, didUpdateLocations: [makeLocation()])
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_lastUpdated_isInitiallyEmpty() {
        let (_, _, _, sut) = makeSUT()
        
        XCTAssertTrue(sut.lastUpdated.contains("--"))
    }
    
    func test_lastUpdated_isUpdatedOnSuccessfulFetch() async {
        let (_, useCase, defaults, sut) = makeSUT()
        XCTAssertEqual(defaults.getValueCount, 1) // on init
        XCTAssertEqual(defaults.setValueCount, 0)
        
        let now = Date()
        defaults.stubbedDate = now
        
        useCase.stub = .init(cache: [], result: makeWeatherInformationArray(), error: nil)
        await sut.getWeather()
        
        XCTAssertEqual(defaults.setValueCount, 1)
        XCTAssertFalse(sut.lastUpdated.contains("--"))
    }
    
    func test_lastUpdated_onInitLoadsExistingDefaultsValue() {
        let defaults = UserDefaultsSpy()
        defaults.stubbedDate = Date()
        let (_, _, _, sut) = makeSUT(defaults: defaults)
        
        XCTAssertFalse(sut.lastUpdated.contains("--"))
    }
    
    // MARK: - Helpers
    
    private class UserDefaultsSpy: UserDefaults {
        
        var setValueCount = 0
        var getValueCount = 0
        var stubbedDate: Date?
        
        override func set(_ value: Any?, forKey defaultName: String) {
            setValueCount += 1
        }
        
        override func object(forKey defaultName: String) -> Any? {
            getValueCount += 1
            return stubbedDate
        }
    }
    
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
        let store = WeatherInformationStore()
        let sut = WeatherViewModel(locationManager: locationManager, useCase: useCase, weatherStore: store, defaults: UserDefaultsSpy())
        checkIsDeallocated(sut: manager, file: file, line: line)
        checkIsDeallocated(sut: locationManager, file: file, line: line)
        checkIsDeallocated(sut: useCase, file: file, line: line)
        checkIsDeallocated(sut: store, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (manager, useCase, sut)
    }
    
    @MainActor
    private func makeSUT(
        isAuthorized: Bool = false,
        defaults: UserDefaultsSpy = .init(),
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (manager: MockCLLocationManager, useCase: MockGetWeatherUseCase, defaults: UserDefaultsSpy, sut: WeatherViewModel) {
        
        let manager = MockCLLocationManager()
        manager.stubbedIsAuthorized = isAuthorized
        let useCase = MockGetWeatherUseCase()
        let locationManager = LocationManager(manager: manager)
        let store = WeatherInformationStore()
        let sut = WeatherViewModel(locationManager: locationManager, useCase: useCase, weatherStore: store, defaults: defaults)
        checkIsDeallocated(sut: manager, file: file, line: line)
        checkIsDeallocated(sut: locationManager, file: file, line: line)
        checkIsDeallocated(sut: useCase, file: file, line: line)
        checkIsDeallocated(sut: store, file: file, line: line)
        checkIsDeallocated(sut: defaults, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (manager, useCase, defaults, sut)
    }
}
