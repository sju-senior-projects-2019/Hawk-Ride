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
   
  /*  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "pickupPoint"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        } else {
            annotationView?.annotation = annotation
        }
        annotationView?.image = UIImage(named: "destinationAnnotation")
        
        return annotationView
    } */
    
    
    
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
   
   
    
    
}
