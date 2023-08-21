//
//  CoreDataWeatherStore.swift
//  WeatherApp
//
//  Created by Alex Motoc on 21.08.2023.
//

import Foundation
import CoreData

public final class CoreDataWeatherStore {
    private static let modelName = "WeatherData"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataWeatherStore.self))
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    enum StoreError: Error {
        case invalidModel
        case loadStore(Error)
    }
    
    public init(storeURL: URL) throws {
        guard let model = Self.model else {
            throw StoreError.invalidModel
        }
        do {
            container = try NSPersistentContainer.load(name: Self.modelName, model: model, url: storeURL)
            context = container.newBackgroundContext()
        } catch {
            throw StoreError.loadStore(error)
        }
    }
    
    func performSync<R>(_ action: (NSManagedObjectContext) -> Result<R, Error>) throws -> R {
        var result: Result<R, Error>!
        let context = self.context // avoid retain cycle
        context.performAndWait {
            result = action(context)
        }
        return try result.get()
    }
}
