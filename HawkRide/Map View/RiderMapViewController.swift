//
//  RideMapViewController.swift
//  Hawk Ride
//
//  Created by Gregory Jones on 2/26/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps

extension GMSMapView {
    func mapStyle(withFilename name: String, andType type: String) {
        do  {
            if let styleURL = Bundle.main.url(forResource: name, withExtension: type) {
                self.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            }  else {
                NSLog("Unable to find style.join")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    }
}

class RiderMapViewController: UIViewController, GMSMapViewDelegate {

    
    var delegate: RiderMapViewControllerDelegate?
   
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        mapView.animate(toLocation: CLLocationCoordinate2DMake(39.995256, -75.241579))
        mapView.animate(toZoom: 15)
        // mapView.delegate = self
        self.mapView.mapStyle(withFilename: "bright", andType: "json");
        
    }
}







