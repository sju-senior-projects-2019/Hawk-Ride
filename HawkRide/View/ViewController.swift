//
//  ViewController.swift
//  HawkRide
//
//  Created by Gregory Jones on 1/29/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import RevealingSplashView
import FirebaseAuth


class ViewController: UIViewController, CLLocationManagerDelegate {
    
    
 
    private var revealingLoaded = false
    @IBOutlet weak var HawkRiderButton: SAButton!
    @IBOutlet weak var HawkDriverButton: SAButton!
    @IBOutlet weak var BecomeAHawkDriverButton:SAButtonPart2!
    var locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
    super.viewDidLoad()
       
        initializeRevealingSplash()
        customNavigationBar()
       checkLocationAuthStatus()
       
    }
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            
        } else {
            // Show alert letting the user know they have to turn this on.
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    func checkLocationAuthStatus(){
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
            
        }else {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    
    func initializeRevealingSplash() {
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
    }
    
    func customNavigationBar() {
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
    
    override var shouldAutorotate: Bool {
        return revealingLoaded
    }
  
}

