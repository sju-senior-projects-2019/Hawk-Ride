//
//  Location.swift
//  
//
//  Created by Gregory Jones on 3/22/19.
//


import UIKit
import MapKit
import CoreLocation


struct Location {
    
   
    var title: String?
    var desc:  String?
    var coordinate: CLLocationCoordinate2D?
    var location: String?
    
    init() {
        
    }
    
    init(title: String, desc: String, coordinate: CLLocationCoordinate2D, location: String) {
        
        self.title = title
        self.desc = desc
        self.coordinate = coordinate
        self.location = location
       
       
    }
    
}


