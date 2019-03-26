//
//  Location.swift
//  
//
//  Created by Gregory Jones on 3/22/19.
//

import Foundation
import UIKit
import GoogleMaps

class Location: NSObject {
    
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var regionRadius: Double
    var location: String?
    var type: String?
    
    var cllocation: CLLocation
    
    init(title: String, cllocation: CLLocation,regionRadius: Double, location: String,type: String,coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate 
        self.regionRadius = regionRadius
        self.location = location
        self.type = type
        self.cllocation = cllocation
        
        
    }
}
