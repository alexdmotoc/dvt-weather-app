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
        let store = WeatherInformationStore()
        let sut = WeatherViewModel(locationManager: locationManager, useCase: useCase, weatherStore: store)
        checkIsDeallocated(sut: manager, file: file, line: line)
        checkIsDeallocated(sut: locationManager, file: file, line: line)
        checkIsDeallocated(sut: useCase, file: file, line: line)
        checkIsDeallocated(sut: store, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (manager, useCase, sut)
    }
}
