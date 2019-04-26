//
//  DriverPickUpMapVC.swift
//  Hawk Ride
//
//  Created by Gregory Jones on 4/7/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Firebase


class DriverPickUpMapVC: UIViewController {
    
  @IBOutlet weak var pickUpMapView: RoundMapView!
    let currentUserId = Auth.auth().currentUser?.uid
    var passengerKey: String!
    var placeMark: MKPlacemark!
    var pickUpCoordinate: CLLocationCoordinate2D!
    
    
    
    func initData(coordinate: CLLocationCoordinate2D, passenger: String) {
        self.pickUpCoordinate = coordinate
        self.passengerKey = passenger
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickUpMapView.delegate = self
        placeMark = MKPlacemark(coordinate: pickUpCoordinate)
        dropPinFor(placeMark: placeMark)
        centerMapOnLocation(location: placeMark.location!)
        
       
        DataService.instance.REF_TRIPS.child(passengerKey).observe(.value) {(tripSnapshot) in
            if tripSnapshot.exists() {
                if tripSnapshot.childSnapshot(forPath: kTRIP_IS_ACCEPTED).value as! Bool {
                    self.dismiss(animated: true, completion: nil)
                  
                }
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        
      }
        
    }
    
    
    @IBAction func acceptBtnWasPressed(_ sender: Any) {
        
        if let driverId = currentUserId {
            DataService.instance.acceptTrip(withPassengerId: passengerKey, forDriverId: driverId)
        }
        
        
        
    }
    
    
    @IBAction func cancelBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
       DataService.instance.REF_TRIPS.removeValue()
    
    }
    
   
    
  
}

extension DriverPickUpMapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let driverAnnotation = annotation as? DriverAnnotation {
            let annotationView: MKAnnotationView = MKAnnotationView(annotation: driverAnnotation, reuseIdentifier: "driver")
            annotationView.image = UIImage(named: "mapcar")
            return annotationView
        }
            // Rider Annotation
        else if let passengerAnnotation = annotation as? PassengerAnnotation {
            let annotationView = MKAnnotationView(annotation: passengerAnnotation, reuseIdentifier: "passengerAnnotation")
            annotationView.image = UIImage(named: "pickup_pin")
            return annotationView
        }
        else if let destinationAnnotation = annotation as? MKPointAnnotation {
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "destinationAnnotation")
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: destinationAnnotation, reuseIdentifier: "destination_pin")
            }else{
                annotationView?.annotation = destinationAnnotation
            }
            
            annotationView!.image = UIImage(named: "pickup_pin")
            return annotationView
            
        }
        
        return nil
        
    }
    
 
    func centerMapOnLocation(location: CLLocation){
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        pickUpMapView.setRegion(region, animated: true)
    }
    
    
    func dropPinFor(placeMark: MKPlacemark) {
        let userAnnotation = MKPointAnnotation()
        userAnnotation.coordinate = placeMark.coordinate
        pickUpMapView.addAnnotation(userAnnotation)
    }
 
    
    
}
