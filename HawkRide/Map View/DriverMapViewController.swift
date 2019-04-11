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

class DriverMapViewController: UIViewController {
   
    //MARK: - Properties
    var sidebarView: SidebarViewDriver!
    var blackScreen: UIView!
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 1000
    var currentUserId: String?
    
    //Coordinates of Locations
    var currentLocationLatitude = CLLocationDegrees()
    var currentLocationLongitude = CLLocationDegrees()
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        mapView.delegate = self
        checkLocationAuthStatus()
        centerMapOnUserLocation()
        setupMenuButton()
        setupBlackScreen()
        setupSideBarView()
        currentUserId = Auth.auth().currentUser?.uid
        DataService.instance.REF_DRIVERS.observe(.value, with: {(snapshot) in
           self.loadDriverAnnotationsFromFB()
        })
        
       
    
    }
    
    func observePassengerAndDrivers() {
        
    
    }
    
     // MARK: - Handlers
    
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
    
    //MARK: - Navigation
    func checkLocationAuthStatus(){
        if CLLocationManager.authorizationStatus() == .authorizedAlways
        {
            locationManager.startUpdatingLocation()
        }
        else
        {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func loadDriverAnnotationsFromFB() {
        DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let driverSnapshot = snapshot.children.allObjects as? [DataSnapshot]
            {
                for driver in driverSnapshot
                {
                    if driver.hasChild(kCOORDINATES)
                    {
                        if driver.childSnapshot(forPath: kIS_PICKUP_MODE_ENABLED).value as? Bool == true
                        {
                            if let driverDict = driver.value as? Dictionary<String, AnyObject>
                            {
                                let coordinateArray = driverDict[kCOORDINATES] as! NSArray
                                let driverCoordinate = CLLocationCoordinate2D(latitude: coordinateArray[0] as! CLLocationDegrees, longitude: coordinateArray[1] as! CLLocationDegrees)
                                
                                let annotation = DriverAnnotation(coordinate: driverCoordinate, withKey: driver.key)
                                
                                var driverIsVisible: Bool
                                {
                                    return self.mapView.annotations.contains(where: { (annotation) -> Bool in
                                        if let driverAnnotation = annotation as? DriverAnnotation
                                        {
                                            if driverAnnotation.key == driver.key
                                            {
                                                driverAnnotation.update(annotationPosition: driverAnnotation, withCoordinate: driverCoordinate)
                                                return true
                                            }
                                        }
                                        return false
                                    })
                                }
                                
                                if !driverIsVisible {
                                    self.mapView.addAnnotation(annotation)
                                }
                            }
                        }
                        else
                        {
                            for annotation in self.mapView.annotations
                            {
                                if annotation.isKind(of: DriverAnnotation.self)
                                {
                                    if let annotation = annotation as? DriverAnnotation
                                    {
                                        if annotation.key == driver.key
                                        {
                                            self.mapView.removeAnnotation(annotation)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
     
    }
        
  }
    


//MARK: - Navigation
extension DriverMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthStatus()
        
        if status == .authorizedAlways {
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .follow
        }
    }
}


extension DriverMapViewController: MKMapViewDelegate {
   
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        UpdateService.instance.updateDriverLocation(withCoordinate: userLocation.coordinate)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let identifier = "driver"
            var view: MKAnnotationView
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.image = UIImage(named: "map-vehicle-icon-xl")
            return view
        }
        else if let annotation = annotation as? MKPointAnnotation
        {
            let identifier = "destination"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil
            {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            else
            {
                annotationView?.annotation = annotation
            }
            annotationView?.image = UIImage(named:"destinationAnnotation")
            return annotationView
        }
        return nil
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

extension DriverMapViewController {
    
    func centerMapOnUserLocation(){
        let coordinateRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
}




    

