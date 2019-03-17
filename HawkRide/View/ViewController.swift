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
import RevealingSplashView


class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    private var revealingLoaded = false
    var mapView: GMSMapView!
    let locationManager = CLLocationManager()
    @IBOutlet weak var HawkRiderButton: SAButton!
    @IBOutlet weak var HawkDriverButton: SAButton!
    @IBOutlet weak var BecomeAHawkDriverButton: SAButtonPart2!
    
    
    
    override var shouldAutorotate: Bool {
        return revealingLoaded
    }
  
    override func viewDidLoad() {
    super.viewDidLoad()
    
    //Initialize a revealing Splash with with the iconImage, the initial size and the background color
    let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "Hawk")!,iconInitialSize: CGSize(width:145, height:86), backgroundColor: UIColor(red: 161/255, green: 31/255, blue: 53/255, alpha: 1))
    
    self.view.addSubview(revealingSplashView)
    
    revealingSplashView.duration = 5
    revealingSplashView.iconColor = UIColor.red
    revealingSplashView.useCustomIconColor = false
   // revealingSplashView.animationType = SplashAnimationType.rotateOut
    revealingSplashView.heartAttack = true
    
    revealingSplashView.startAnimation(){
        self.revealingLoaded = true
        self.setNeedsStatusBarAppearanceUpdate()
        print("Completed")
    }
    
     //Set up Map View
    
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
    
    /* Customizing the navigation bar */
    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Hello", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
    self.navigationItem.backBarButtonItem?.title = ""
    self.navigationItem.backBarButtonItem = UIBarButtonItem()
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    self.navigationController?.navigationBar.shadowImage = UIImage()
    self.navigationController?.navigationBar.isTranslucent = true
    self.navigationController?.view.backgroundColor = .clear
    
  }
    override var prefersStatusBarHidden: Bool {
        return !UIApplication.shared.isStatusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.fade
    }
  
}

