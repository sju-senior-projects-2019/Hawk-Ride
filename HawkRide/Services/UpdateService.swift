//
//  UpdateService.swift
//  Hawk Ride
//
//  Created by Gregory Jones on 4/10/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Firebase

class UpdateService  {
    
    static var instance = UpdateService()
    
    func updateUserLocation(withCoordinate coordinate: CLLocationCoordinate2D) {
        
        DataService.instance.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let userSnapshot = snapshot.children.allObjects as? [DataSnapshot]
            {
                for user in userSnapshot
                {
                    if user.key == Auth.auth().currentUser?.uid
                    {
                        DataService.instance.REF_USERS.child(user.key).updateChildValues([kCOORDINATES: [coordinate.latitude, coordinate.longitude]])
                    }
                }
            }
        })
    }
    func updateDriverLocation(withCoordinate coordinate: CLLocationCoordinate2D) {
        
        DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let driverSnapshot = snapshot.children.allObjects as? [DataSnapshot]
            {
                for driver in driverSnapshot
                {
                    if driver.key == Auth.auth().currentUser?.uid
                    {
                        if driver.childSnapshot(forPath: kIS_PICKUP_MODE_ENABLED).value as? Bool == true
                        {
                            DataService.instance.REF_DRIVERS.child(driver.key).updateChildValues([kCOORDINATES: [coordinate.latitude, coordinate.longitude]])
                        }
                    }
                }
            }
        })
    }
}
