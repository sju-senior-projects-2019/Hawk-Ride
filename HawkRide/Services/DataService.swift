//
//  DataService.swift
//  Hawk Ride
//
//  Created by Gregory Jones on 3/25/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//

import Foundation
import Firebase
import MapKit

let ref = Database.database().reference(fromURL: "https://hawk-ride-233122.firebaseio.com/")

class DataService {
    static let instance = DataService()
   
    // Create a child
    private let DATABASE_REF = ref
    private let USER_REF = ref.child("riders")
    private let DRIVER_REF = ref.child("drivers")
    private let TRIPS_REF = ref.child("trips")
    
    
    var databaseRef : DatabaseReference {
        return DATABASE_REF
    }
    
    var usersRef: DatabaseReference {
        return USER_REF
    }
    
    var driversRef: DatabaseReference {
        return DRIVER_REF
    }
    
    var tripsRef: DatabaseReference {
        return TRIPS_REF
    }
   
    
    //MARK:- users
    func createFirebaseDBUser(uID: String, userData: Dictionary<String,Any>, isDriver: Bool){
        if isDriver {
            driversRef.child(uID).updateChildValues(userData)
        }else {
            usersRef.child(uID).updateChildValues(userData)
        }
    }
    
    func updateUser(id: String, with userData: [String: Any]){
        
        usersRef.child(id).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists()  {
                self.usersRef.child(id).updateChildValues(userData)
                
            }
        }
        
    }
    
    func deleteFromUser(id: String, value: String){
        usersRef.child(id).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists()  {
                self.usersRef.child(id).child(value).removeValue()
                
            }
        }
    }
    func checkUser(id:String, forValue value: String, completion: @escaping (Bool) -> Void ){
        
        usersRef.child(id).child(value).observeSingleEvent(of: .value) { (snapShot) in
            if snapShot.exists() {
                completion(true)
            }else{
                completion(false)
            }
        }
    }
    
    func updateUserLocation(userID: String, withCoordinate coordinate: CLLocationCoordinate2D ){
        
        usersRef.child(userID).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists()  {
                self.usersRef.child(userID).updateChildValues([kCOORDINATES: [coordinate.latitude,coordinate.longitude]])
            }
        }
        
    }
    
}
