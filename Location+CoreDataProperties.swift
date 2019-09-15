//
//  Location+CoreDataProperties.swift
//  MyLocationsDemo
//
//  Created by Abdallah on 9/9/19.
//  Copyright © 2019 Abdallah Eldesoky. All rights reserved.
//
//

import Foundation
import CoreData
import CoreLocation

extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var category: String
    @NSManaged public var date: Date
    @NSManaged public var placemark: CLPlacemark?
    @NSManaged public var locationDescription: String
    @NSManaged public var photoID: NSNumber?
}
