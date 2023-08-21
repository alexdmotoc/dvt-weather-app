//
//  CoreDataHelpers.swift
//  WeatherApp
//
//  Created by Alex Motoc on 21.08.2023.
//

import Foundation
import CoreData

extension NSPersistentContainer {
    
    /// Since the store is not located in the main bundle, we need this custom initializer for the persistent container
    ///
    static func load(name: String, model: NSManagedObjectModel, url: URL) throws -> NSPersistentContainer {
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        
        var loadError: Error?
        container.loadPersistentStores { _, error in loadError = error }
        if let loadError { throw loadError }
        
        return container
    }
}

extension NSManagedObjectModel {
    /// We need this custom initialized because our store is not located in the main bundle.
    /// 
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}
