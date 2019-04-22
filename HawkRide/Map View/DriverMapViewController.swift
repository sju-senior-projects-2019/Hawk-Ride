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
    @IBOutlet weak var pickUpSwitch: UISwitch!
    
    
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
       
        // Display driver annotations on the map
        DataService.instance.REF_DRIVERS.observe(.value) {
        (snapshot) in
        DataService.instance.loadDriverAnnotaitonsFromDB(mapView: self.mapView)
            
            if let userId = Auth.auth().currentUser?.uid {
                    DataService.instance
                        .passengerIsOnTrip(passengerId: userId, handler: { (isOnTrip, driverId, tripId) in
                            self.zoom(toFitAnnotationsFromMapView: self.mapView, forActiveTripWithDriver: true, withKey: driverId)
                 })
            }
     
        }
        
        // If there is  a new trip display it for the available drivers
        
        DataService.instance.observeTrips { (tripDictionary) in
            if let tripDict = tripDictionary {
                let pickUpCoordinateArray =
                tripDict[kPICKUP_COORDINATE] as! [CLLocationDegrees]
                let passengerId = tripDict[kPASSENGER] as! String
                let isTripAccepted = tripDict[kTRIP_IS_ACCEPTED] as! Bool
                
                if let driverID = Auth.auth().currentUser?.uid {
                    DataService.instance.driverIsAvailable(id: driverID, completion: { (isAvailable) in
                        if let isAvailable = isAvailable {
                            guard isTripAccepted == false else
                            {return}
                            if isAvailable == true {
                               
                                let storyboard = UIStoryboard(name: MAIN_STORYBOARD, bundle: Bundle.main)
                                let pickupVC = storyboard.instantiateViewController(withIdentifier:VC_PICKUP) as? DriverPickUpMapVC
                                
                                pickupVC?.initData(coordinate: CLLocationCoordinate2D(latitude: pickUpCoordinateArray[0], longitude: pickUpCoordinateArray[1]), passenger:
                                passengerId)
                                self.present(pickupVC!, animated: true)
                            }
                        }
                    })
                }
            }
        }
        
        DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]
            {
                for snap in snapshot
                {
                    if snap.key == Auth.auth().currentUser?.uid
                    {
                    
                        self.pickUpSwitch.isHidden = false
                        
                        let switchStatus = snap.childSnapshot(forPath: kIS_PICKUP_MODE_ENABLED).value as! Bool
                        self.pickUpSwitch.isOn = switchStatus
                       
                    }
                }
            }
        })
    }

    
    @IBAction func switchWasToggled(_ sender: Any) {
        let currentUserId = Auth.auth().currentUser?.uid
        if pickUpSwitch.isOn {
            DataService.instance.REF_DRIVERS.child(currentUserId!).updateChildValues([kIS_PICKUP_MODE_ENABLED: true])
        }
        else {
            DataService.instance.REF_DRIVERS.child(currentUserId!).updateChildValues([kIS_PICKUP_MODE_ENABLED: false])
        }
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
        if let id = Auth.auth().currentUser?.uid {
      DataService.instance.updateDriverLocation(userID: id, withCoordinate: userLocation.coordinate)
            DataService.instance.userIsDriver(userId: id) { (isDriver) in
                if isDriver {
                    DataService.instance
                        .driverIsOnTrip(driverKey: id, handler: { (isOnTrip, driverKey, tripKey) in
                            if isOnTrip! {
                                self.zoom(toFitAnnotationsFromMapView: self.mapView, forActiveTripWithDriver: true, withKey: driverKey)
                            } else {
                                self.centerMapOnUserLocation()
                            }
                        })
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let identifier = "driver"
            var view: MKAnnotationView
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.image = UIImage(named: "mapcar")
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
    
    func zoom(toFitAnnotationsFromMapView mapView: MKMapView, forActiveTripWithDriver: Bool, withKey key: String?) {
        if mapView.annotations.count == 0 {
            return
        }
        var topLeftCoordinate = CLLocationCoordinate2D(latitude: -90, longitude: 180)
        var bottomRightCoordinate = CLLocationCoordinate2D(latitude: 90, longitude: -180)
        
        if forActiveTripWithDriver {
            for annotation in mapView.annotations {
                if let annotation = annotation as? DriverAnnotation {
                    if annotation.driverID == key {
                        topLeftCoordinate.longitude = fmin(topLeftCoordinate.longitude, annotation.coordinate.longitude)
                        topLeftCoordinate.latitude = fmax(topLeftCoordinate.latitude, annotation.coordinate.latitude)
                        bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude, annotation.coordinate.longitude)
                        bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, annotation.coordinate.latitude)
                    }
                } else {
                    topLeftCoordinate.longitude = fmin(topLeftCoordinate.longitude, annotation.coordinate.longitude)
                    topLeftCoordinate.latitude = fmax(topLeftCoordinate.latitude, annotation.coordinate.latitude)
                    bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude, annotation.coordinate.longitude)
                    bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, annotation.coordinate.latitude)
                }
            }
        }
        
        for annotation in mapView.annotations where !annotation.isKind(of: DriverAnnotation.self) {
            topLeftCoordinate.longitude = fmin(topLeftCoordinate.longitude, annotation.coordinate.longitude)
            topLeftCoordinate.latitude = fmax(topLeftCoordinate.latitude, annotation.coordinate.latitude)
            bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude, annotation.coordinate.longitude)
            bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, annotation.coordinate.latitude)
        }
        
        var region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(topLeftCoordinate.latitude - (topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 0.5, topLeftCoordinate.longitude + (bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 0.5), span: MKCoordinateSpan(latitudeDelta: fabs(topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 2.0, longitudeDelta: fabs(bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 2.0))
        
        region = mapView.regionThatFits(region)
        mapView.setRegion(region, animated: true)
        
        
    }
    
    
}




    

