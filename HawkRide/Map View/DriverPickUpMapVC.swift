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
    var regionRadius: CLLocationDistance = 2000
    var pin: MKPlacemark? = nil
    
    @IBAction func acceptBtnWasPressed(_ sender: Any) {
    }
    
    @IBAction func cancelBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        }
    
  
}

extension DriverPickUpMapVC: MKMapViewDelegate {
 
    
    
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            pickUpMapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    
    func dropPinFor(placemark: MKPlacemark) {
        pin = placemark
    
        for annotation in pickUpMapView.annotations {
            pickUpMapView.removeAnnotation(annotation)
        }
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        
        pickUpMapView.addAnnotation(annotation)
    }
   
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        UpdateService.instance.updateDriverLocation(withCoordinate: userLocation.coordinate)
    }
    
    
}
