//
//  DriverAnnotation.swift
//  Hawk Ride
//
//  Created by Gregory Jones on 3/31/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//

import Foundation
import MapKit

class DriverAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var driverID: String
    
    init(coordinate: CLLocationCoordinate2D, driverID: String) {
        self.coordinate = coordinate
        self.driverID = driverID
    }
    
    
    func update(withCoordinate coordinate: CLLocationCoordinate2D){
        let location = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        UIView.animate(withDuration: 0.2) {
            self.coordinate = location
        }
    }
    
    
}

