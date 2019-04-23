//
//  PassengerAnnotation.swift
//  Hawk Ride
//
//  Created by Gregory Jones on 4/5/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//

import Foundation
import MapKit

class PassengerAnnotation: NSObject, MKAnnotation {
   dynamic var coordinate: CLLocationCoordinate2D
    var key: String
    
    init(coordinate: CLLocationCoordinate2D, key: String) {
        self.coordinate = coordinate
        self.key = key
        
        super.init()
    }
    
}
