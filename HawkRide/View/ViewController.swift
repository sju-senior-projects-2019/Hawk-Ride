//
//  ViewController.swift
//  HawkRide
//
//  Created by Gregory Jones on 1/29/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import GeoFire

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    //var mapView: GMSMapView!
   // let locationManager = CLLocationManager()
    @IBOutlet weak var HawkRiderButton: SAButton!
    @IBOutlet weak var HawkDriverButton: SAButton!
    @IBOutlet weak var BecomeAHawkDriverButton: SAButtonPart2!
    
  override func viewDidLoad() {
    super.viewDidLoad()
  //  setUpMapView()
   
    /* Customizing the navigation bar */
    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Hello", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
    self.navigationItem.backBarButtonItem?.title = ""
    self.navigationItem.backBarButtonItem = UIBarButtonItem()
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    self.navigationController?.navigationBar.shadowImage = UIImage()
    self.navigationController?.navigationBar.isTranslucent = true
    self.navigationController?.view.backgroundColor = .clear
}
    
 /*   func setUpMapView() {
        let camera=GMSCameraPosition.camera(withLatitude: 27.18096, longitude: 31.18368, zoom: 10)
        mapView=GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        self.mapView.delegate = self
        /// get user location
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate =  self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        mapView.camera = camera
    } */
   
}

