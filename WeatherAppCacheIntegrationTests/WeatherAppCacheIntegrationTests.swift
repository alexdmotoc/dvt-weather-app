//
//  WeatherAppCacheIntegrationTests.swift
//  WeatherAppCacheIntegrationTests
//
//  Created by Alex Motoc on 21.08.2023.
//

import XCTest
import WeatherApp

final class WeatherAppCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    func test_load_onEmptyStoreDeliversEmptyArray() throws {
        let sut = makeSUT()
        
        let items = try sut.load()
        
        XCTAssertTrue(items.isEmpty)
    }
    
    func test_load_deliversSavedItemsOnASeparateInstance() throws {
        let sutLoad = makeSUT()
        let sutSave = makeSUT()
        let itemsToSave = makeWeatherInformationArray()
        
        try sutSave.save(itemsToSave)
        
        let savedItems = try sutLoad.load()
        XCTAssertEqual(savedItems, itemsToSave)
    }
    
    func test_save_overwritesPreviousItems() throws {
        let sutLoad = makeSUT()
        let sutSave = makeSUT()
        let itemsToSave1 = makeWeatherInformationArray(name: "mock1")
        let itemsToSave2 = makeWeatherInformationArray(name: "mock2")
        
        try sutSave.save(itemsToSave1)
        try sutSave.save(itemsToSave2)
        
        let savedItems = try sutLoad.load()
        XCTAssertEqual(savedItems, itemsToSave2)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> WeatherCacheImpl {
        let store = try! CoreDataWeatherStore(storeURL: testSpecificStoreURL())
        let sut = WeatherCacheImpl(store: store)
        checkIsDeallocated(sut: store, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return sut
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
