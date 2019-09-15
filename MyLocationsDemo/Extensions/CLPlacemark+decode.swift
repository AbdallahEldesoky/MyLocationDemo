//
//  Extenision.swift
//  MyLocationsDemo
//
//  Created by Abdallah on 9/8/19.
//  Copyright © 2019 Abdallah Eldesoky. All rights reserved.
//

import Foundation
import CoreLocation


extension CLPlacemark {
    
    func decode() -> String {
        
        var line1 = ""
        var line2 = ""
        
        if let sub = self.subThoroughfare {
            line1 += sub + ", "
        }
        
        if let thoroughfare = self.thoroughfare {
            line1 += thoroughfare
        }
        
        if let locality = self.locality {
            line2 += locality + ", "
        }
        
        if let area = self.administrativeArea {
            line2 += area + ", "
        }
        
        if let postalCode = self.postalCode {
            line2 += postalCode
        }
        
        return line1 + "\n" + line2
    }
}
