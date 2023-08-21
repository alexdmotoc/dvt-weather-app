//
//  CoreDataWeatherStore+WeatherStore.swift
//  WeatherApp
//
//  Created by Alex Motoc on 21.08.2023.
//

import Foundation
import CoreData

extension CoreDataWeatherStore: WeatherStore {
    public func save(_ weather: [WeatherInformation]) throws {
        try performSync { context in
            Result {
                _ = weather.enumerated().map { WeatherInformationMO.insertedInto(context, from: $1, order: $0) }
                try context.save()
            }
        }
    }
    
    public func load() throws -> [WeatherInformation] {
        try performSync { context in
            Result {
                try getAllWeatherInformation(context: context).map { $0.local }
            }
        }
    }
    
    public func deleteAllItems() throws {
        try performSync { context in
            Result {
                try getAllWeatherInformation(context: context).forEach { context.delete($0) }
                try context.save()
            }
        }
    }
    
    private func getAllWeatherInformation(context: NSManagedObjectContext) throws -> [WeatherInformationMO] {
        let request = WeatherInformationMO.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WeatherInformationMO.order, ascending: true)]
        return try context.fetch(request)
    }
}
