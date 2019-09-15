//
//  Location+CoreDataClass.swift
//  MyLocationsDemo
//
//  Created by Abdallah on 9/9/19.
//  Copyright © 2019 Abdallah Eldesoky. All rights reserved.
//
//

import Foundation
import CoreData
import CoreLocation
import MapKit

@objc(Location)
public class Location: NSManagedObject, MKAnnotation {
    
    public var coordinate: CLLocationCoordinate2D{
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public var title: String? {
        
        if locationDescription.isEmpty {
            return "No Description"
        } else {
            return locationDescription
        }
    }
    
    public var subtitle: String? {
        return category
    }

    var hasPhoto: Bool {
        return photoID != nil
    }
    
    var photoURL: URL {
        
        assert(photoID != nil, "No PhotoID set")
        
        let fileName = "Photo-\(photoID!.intValue).jpg"
        return appDocumentsDirectory.appendingPathComponent(fileName)
    }
    
    var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoURL.path)
    }
    
    class func nextPhotoID() -> Int{
        
        let userDefaults = UserDefaults.standard
        let currentID = userDefaults.integer(forKey: "PhotoID") + 1
        userDefaults.set(currentID, forKey: "PhotoID")
        userDefaults.synchronize()
        return currentID
    }
    
     func deletePhotoFile() {
        if hasPhoto {
            do {
                try FileManager.default.removeItem(at: photoURL)
            } catch {
                print("Error Removing File: \(error)")
            }
        }
    }
}
