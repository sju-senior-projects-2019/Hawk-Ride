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

fileprivate  let DB_BASE = Database.database().reference()

final class DataService {
   
    static let instance = DataService()
    
    private init(){}
   
    // Create a child
    private let _REF_BASE = DB_BASE
    private let _REF_USERS = DB_BASE.child("riders")
    private let _REF_DRIVERS = DB_BASE.child("drivers")
    private let _REF_TRIPS = DB_BASE.child("trips")
    
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_DRIVERS: DatabaseReference {
        return _REF_DRIVERS
    }
    
    var REF_TRIPS: DatabaseReference {
        return _REF_TRIPS
    }
   
    
    //MARK:- users
    func createFirebaseDBUser(uID: String, userData: Dictionary<String,Any>, isDriver: Bool){
        if isDriver {
          REF_DRIVERS.child(uID).updateChildValues(userData)
        }else {
           REF_USERS.child(uID).updateChildValues(userData)
        }
    }
    
    func updateUser(id: String, with userData: [String: Any]){
        
        REF_USERS.child(id).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists()  {
                self.REF_USERS.child(id).updateChildValues(userData)
                
            }
        }
        
    }
    func deleteFromUser(id: String, value: String){
        REF_USERS.child(id).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists()  {
                self.REF_USERS.child(id).child(value).removeValue()
                
            }
        }
    }
    
    func checkUser(id:String, forValue value: String, completion: @escaping (Bool) -> Void ){
        
        REF_USERS.child(id).child(value).observeSingleEvent(of: .value) { (snapShot) in
            if snapShot.exists() {
                completion(true)
            }else{
                completion(false)
            }
        }
    }
    
    func updateUserLocation(userID: String, withCoordinate coordinate: CLLocationCoordinate2D ){
        
        REF_USERS.child(userID).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists()  {
                self.REF_USERS.child(userID).updateChildValues([kCOORDINATES: [coordinate.latitude,coordinate.longitude]])
            }
        }
        
    }
    
    func passengerIsOnTrip(passengerId: String, handler: @escaping (_ status: Bool, _ driverKey: String?, _ tripKey: String?) -> Void) {
            REF_TRIPS.observe(.value, with: { (tripSnapshot) in
            if let tripSnapshot = tripSnapshot.children.allObjects as? [DataSnapshot] {
                for trip in tripSnapshot {
                    if trip.key == passengerId {
                        if trip.childSnapshot(forPath: kTRIP_IS_ACCEPTED).value as? Bool == true {
                            let driverId = trip.childSnapshot(forPath: kDRIVERID).value as? String
                            handler(true, driverId, trip.key)
                        } else {
                            handler(false, nil, nil)
                        }
                    }
                }
            }
        })
    }
    
    //MARK:- drivers
    
    func userIsDriver(userId: String, handler: @escaping (_ status: Bool) -> Void) {
        
       REF_DRIVERS.child(userId).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                handler(true)
            }else{
                handler(false)
            }
        }
    }
    
    func updateDriverLocation(userID: String, withCoordinate coordinate: CLLocationCoordinate2D ){
        
       REF_DRIVERS.child(userID).observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.exists() {
                
                if  snapshot.childSnapshot(forPath: kIS_PICKUP_MODE_ENABLED).value as! Bool {
                    self.REF_DRIVERS.child(userID).updateChildValues([kCOORDINATES: [coordinate.latitude,coordinate.longitude]])
                }
            }
            
        }
        
    }
    
    
    func driverIsAvailable(id:String, completion: @escaping (Bool?)-> Void){
       REF_DRIVERS.child(id).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                if snapshot.childSnapshot(forPath: kIS_PICKUP_MODE_ENABLED).value as? Bool == true &&
                    snapshot.childSnapshot(forPath: kDRIVER_IS_ON_TRIP).value as? Bool == false {
                    completion(true)
                }else {
                    completion(false)
                }
            }
        }
    }
    
    func driverIsOnTrip(driverKey: String, handler: @escaping (_ status: Bool?, _ driverKey: String?, _ tripKey: String?) -> Void) {
        
        DataService.instance.REF_DRIVERS.child(driverKey).child(kDRIVER_IS_ON_TRIP).observe(.value, with: { (driverTripStatusSnapshot) in
            
            if let driverTripStatusSnapshot = driverTripStatusSnapshot.value as? Bool
            {
                if driverTripStatusSnapshot == true
                {
                    DataService.instance.REF_TRIPS.observeSingleEvent(of: .value, with: { (tripSnapshot) in
                        
                        if let tripSnapshot = tripSnapshot.children.allObjects as? [DataSnapshot]
                        {
                            for trip in tripSnapshot
                            {
                                if trip.childSnapshot(forPath:kDRIVERS).value as? String == driverKey
                                {
                                    handler(true, driverKey, trip.key)
                                }
                                else
                                {
                                    return
                                }
                            }
                        }
                    })
                }
                else
                {
                    handler(false, nil, nil)
                }
            }
        })
    }
    
    func loadDriverAnnotaitonsFromDB(mapView: MKMapView){
        REF_DRIVERS.observeSingleEvent(of: .value) { (snapshot) in
            for snapshot in snapshot.children.allObjects as! [DataSnapshot] {
                
                if snapshot.hasChild(kCOORDINATES) {
                    if  snapshot.childSnapshot(forPath: kIS_PICKUP_MODE_ENABLED).value as! Bool {
                        
                        let driverDict = snapshot.value as! [String: Any]
                        let coordinateArray = driverDict[kCOORDINATES] as! [CLLocationDegrees]
                        let location = CLLocationCoordinate2D(latitude: coordinateArray[0], longitude: coordinateArray[1])
                        
                        let driverAnnotation = DriverAnnotation(coordinate: location, driverID: snapshot.key)
                        
                        var driverIsVisible: Bool {
                            return mapView.annotations.contains(where: { (annotation) -> Bool in
                                if let driverAnnotation = annotation as? DriverAnnotation {
                                    if  driverAnnotation.driverID == snapshot.key {
                                        driverAnnotation.update(withCoordinate: location)
                                        return true
                                    }
                                }
                                return false
                            })
                        }
                        // if driver is not on the map add him
                        if !driverIsVisible {
                            mapView.addAnnotation(driverAnnotation)
                        }
                    }else {
                        // if pick up mode is not enabled remove driver annotation
                        for annotation in mapView.annotations {
                            if annotation.isKind(of: DriverAnnotation.self) {
                                if let annotation = annotation as? DriverAnnotation {
                                    if annotation.driverID == snapshot.key {
                                        mapView.removeAnnotation(annotation)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    //MARK:- trips
    func createTrip(){
        if let userId = Auth.auth().currentUser?.uid {
            
            REF_USERS.child(userId).observeSingleEvent(of: .value) { (snapshot) in
                if let snapshot = snapshot.value as? [String: Any] {
                    let pickUpCoordinate = snapshot[kCOORDINATES] as? NSArray
                    let destinationCoordinate = snapshot[kDESTINATION_COORDINTE] as? NSArray
                    
                    let tripData = [kPICKUP_COORDINATE: pickUpCoordinate as Any,
                                    kDESTINATION_COORDINTE: destinationCoordinate as Any,
                                    kPASSENGER: userId,
                                    kTRIP_IS_ACCEPTED: false] 
                    self.REF_TRIPS.child(userId).updateChildValues(tripData)
                    
                }
            }
            
        }
    }
    
    func fetchTrip(forDriver driverId: String, completion: @escaping (_ trip: [String:Any]?)->Void){
       REF_TRIPS.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                for tripSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
                    if tripSnapshot.childSnapshot(forPath: kDRIVERID).value as? String == driverId {
                        completion(tripSnapshot.value as? [String:Any])
                    }
                }
            }
        }
    }
    
    func observeTrips(completion: @escaping ([String:Any]?)-> Void){
        
       REF_TRIPS.observe(.value) { (snapshot) in
            if snapshot.exists() {
                
                for tripSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
                    if let tripDict = tripSnapshot.value as? [String: Any] {
                        completion(tripDict)
                    }
                }
            }
        }
    }
    
    func acceptTrip(withPassengerId passengerId: String,forDriverId driverId: String) {
        REF_TRIPS.child(passengerId).updateChildValues([kTRIP_IS_ACCEPTED: true,
                                                       kDRIVERID: driverId])
        REF_DRIVERS.child(driverId).updateChildValues([kDRIVER_IS_ON_TRIP: true])
    }
    
    func cancelTrip(withPassengerId passengerId: String,forDriverId driverId: String) {
        REF_TRIPS.child(passengerId).removeValue()
        REF_DRIVERS.child(driverId).updateChildValues([kDRIVER_IS_ON_TRIP: false])
       REF_USERS.child(passengerId).child(kDESTINATION_COORDINTE).removeValue()
    }
    
    
}




