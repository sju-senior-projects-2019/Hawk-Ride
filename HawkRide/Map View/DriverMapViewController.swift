//
//  DriverMapViewController.swift
//  Hawk Ride
//
//  Created by Gregory Jones on 2/26/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import RevealingSplashView



class DriverMapViewController: UIViewController, MKMapViewDelegate {
   
    //MARK: - Properties
    var sidebarView: SidebarViewDriver!
    var blackScreen: UIView!
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 550
   
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuButton()
        setupBlackScreen()
        setupSideBarView()
        checkLocationServices()
       // loadDriverAnnotationsFromFB()
        
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
        }
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let identifier = "driver"
            var view: MKAnnotationView
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.image = UIImage(named: "hawkcar")
            return view
        }
        return nil
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            break
        case .denied:
            // Show alert instructing them how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Show an alert letting them know what's up
            break
        case .authorizedAlways:
            break
        }
    }
    
  /*  func loadDriverAnnotationsFromFB() {
        
        DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let driverSnapshot = snapshot.children.allObjects as? [DataSnapshot]
            {
                for driver in driverSnapshot
                {
                    if driver.hasChild(COORDINATE)
                    {
                        if driver.childSnapshot(forPath: ACCOUNT_PICKUP_MODE_ENABLED).value as? Bool == true
                        {
                            if let driverDict = driver.value as? Dictionary<String, AnyObject>
                            {
                                let coordinateArray = driverDict[COORDINATE] as! NSArray
                                let driverCoordinate = CLLocationCoordinate2D(latitude: coordinateArray[0] as! CLLocationDegrees, longitude: coordinateArray[1] as! CLLocationDegrees)
                                let annotation = DriverAnnotation(coordinate: driverCoordinate, withKey: driver.key)
                            }
                          }
                         }
                      }
                    }
                })
         } */


    
    //MARK: - Handlers
    
    /* Hamburger Menu Button
     * Using navigation bar button to integrate the interaction with the menu icon image
     * It calls the function btnMenuAction to interacte with the animation to display the slide menu
     */
   
    func setupMenuButton() {
        let btnMenu = UIButton(frame: CGRect(x: 0.0, y:0.0, width: 24, height: 18))
        btnMenu.setBackgroundImage(UIImage(named:"Menu"), for: .normal)
        btnMenu.addTarget(self, action: #selector(btnMenuAction),for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btnMenu)
    }
    
    /* Animating the slide menu feature & designing the layout */
    @objc func btnMenuAction() {
        blackScreen.isHidden=false
        UIView.animate(withDuration: 0.5, animations: {
            self.sidebarView.frame=CGRect(x: 0, y: 0, width: 250, height: self.sidebarView.frame.height)
        }) { (complete) in
            self.blackScreen.frame=CGRect(x: self.sidebarView.frame.width, y: 0, width: self.view.frame.width-self.sidebarView.frame.width, height: self.view.bounds.height+100)
        }
    }
    
    
    func setupSideBarView() {
        sidebarView = SidebarViewDriver(frame: CGRect(x: 0, y: 0, width: 0, height: self.view.frame.height))
        sidebarView.delegate = self
        sidebarView.layer.zPosition=100
        self.view.isUserInteractionEnabled=true
        self.navigationController?.view.addSubview(sidebarView)
    }
    
    func setupBlackScreen() {
        blackScreen=UIView(frame: self.view.bounds)
        blackScreen.backgroundColor=UIColor(white: 0, alpha: 0.5)
        blackScreen.isHidden=true
        self.navigationController?.view.addSubview(blackScreen)
        blackScreen.layer.zPosition=99
        let tapGestRecognizer = UITapGestureRecognizer(target: self, action: #selector(blackScreenTapAction(sender:)))
        blackScreen.addGestureRecognizer(tapGestRecognizer)
    }
    
    
    @objc func blackScreenTapAction(sender: UITapGestureRecognizer) {
        blackScreen.isHidden=true
        blackScreen.frame=self.view.bounds
        UIView.animate(withDuration: 0.3) {
            self.sidebarView.frame=CGRect(x: 0, y: 0, width: 0, height: self.sidebarView.frame.height)
        }
    }
 
}

extension DriverMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}


extension DriverMapViewController: SidebarDriverViewDelegate {
    
    /* Adding the rows to the side bar */
    func sidebarDidSelectRow(rowDriver: RowDriver) {
        blackScreen.isHidden=true
        blackScreen.frame=self.view.bounds
        UIView.animate(withDuration: 0.3) {
            self.sidebarView.frame=CGRect(x: 0, y: 0, width: 0, height: self.sidebarView.frame.height)
        }
        switch rowDriver {
        case .editProfile:
            let controller = EditProfileController()
            self.navigationController?.pushViewController(controller, animated: true)
        case .rideHistory:
            print("Ride History")
        case .schedule:
            print("Schedule")
        case .vehicle:
            print("Vehicle")
        case .becomeAHawkRider:
            print("Become a Hawk Rider")
        case .help:
            print("Help")
        case .settings:
            print("Settings")
        case .pickUpMode:
            print("Pick up mode")
        case .logOut:
            print("Log out")
       case .none:
            break
            // default: //Default will never be executed
       
       
        }
    }
    
}



    

