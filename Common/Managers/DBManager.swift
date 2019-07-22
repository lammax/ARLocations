//
//  DBManager.swift
//  AR Locations
//
//  Created by Mac on 19.07.2019.
//  Copyright © 2019 Lammax. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class DBManager {
    
    static let sharedInstance = DBManager()
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    func loadItems(with request: NSFetchRequest<LocationCoordinate2D> = LocationCoordinate2D.fetchRequest(), completion: @escaping ([LocationCoordinate2D]?) -> Void) {
        guard let locations = self.doFetchRequest(request: request) else {
            completion(nil)
            return
        }
        completion(locations)
    }
    
    private func doFetchRequest(request: NSFetchRequest<LocationCoordinate2D>) -> [LocationCoordinate2D]? {
        do {
            return try self.context.fetch(request)
        } catch {
            print("Error loading context \(error.localizedDescription)")
            return nil
        }
    }
    
    private func saveItems() {
        do {
            try self.context.save()
        } catch {
            print("Error saving context \(error.localizedDescription)")
        }
    }

    func newLocation(with location: CLLocation) -> LocationCoordinate2D {
        let newLocation = LocationCoordinate2D(context: context)
        newLocation.latitude = location.coordinate.latitude
        newLocation.longitude = location.coordinate.longitude
        
        self.saveItems()
        
        return newLocation
    }
    
    func delete(location: LocationCoordinate2D) {
        self.context.delete(location)
        self.saveItems()
    }
    
    func clearDB() {
        self.loadItems { (maybeLocations) in
            if let locations = maybeLocations {
                for location in locations {
                    self.delete(location: location)
                }
            }
        }
    }
    
}
