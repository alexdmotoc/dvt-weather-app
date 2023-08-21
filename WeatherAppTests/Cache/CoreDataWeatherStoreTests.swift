//
//  CoreDataWeatherStoreTests.swift
//  WeatherAppTests
//
//  Created by Alex Motoc on 21.08.2023.
//

import XCTest
import WeatherApp

class CoreDataWeatherStoreTests: XCTestCase {
    
    func test_load_returnsEmptyOnEmptyStore() throws {
        let sut = makeSUT()
        
        let items = try sut.load()
        
        XCTAssertTrue(items.isEmpty)
    }
    
    func test_save_returnsNoError() throws {
        let sut = makeSUT()
        let itemsToSave = (0 ..< 5).map { _ in makeWeatherInformationWithForecast() }
        
        try sut.save(itemsToSave)
    }
    
    func test_save_returnsSavedItems() throws {
        let sut = makeSUT()
        let itemsToSave = (0 ..< 5).map { _ in makeWeatherInformationWithForecast() }
        
        try sut.save(itemsToSave)
        let savedItems = try sut.load()
        
        XCTAssertEqual(itemsToSave, savedItems)
    }
    
    func test_deleteAllItems_returnsNoErrorOnEmptyStore() throws {
        let sut = makeSUT()
        try sut.deleteAllItems()
    }
    
    func test_deleteAllItems_emptiesStore() throws {
        let sut = makeSUT()
        let itemsToSave = (0 ..< 5).map { _ in makeWeatherInformationWithForecast() }
        
        try sut.save(itemsToSave)
        var savedItems = try sut.load()
        XCTAssertEqual(itemsToSave, savedItems)
        
        try sut.deleteAllItems()
        savedItems = try sut.load()
        XCTAssertEqual(savedItems, [])
    }
    
    // MARK: - Helpers
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> WeatherStore {
        let url = URL(fileURLWithPath: "/dev/null")
        let store = try! CoreDataWeatherStore(storeURL: url)
        checkIsDeallocated(sut: store, file: file, line: line)
        return store
    }
}
