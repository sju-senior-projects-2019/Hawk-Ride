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
    var route: MKRoute!
    var buttonAction: buttonActionForDrivers!
    @IBOutlet weak var pickUpSwitch: UISwitch!
     @IBOutlet weak var actionButton: RequestCustomButton!
    
    
    //Coordinates of Locations
    var currentLocationLatitude = CLLocationDegrees()
    var currentLocationLongitude = CLLocationDegrees()
    var location = Location()
    
   
    
    
   
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

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
       guard let userId = Auth.auth().currentUser?.uid else {return}
        
        DataService.instance.userIsDriver(userId:userId) {
            (isDriver) in
            if isDriver {
                self.actionButton.isHidden = true
                self.actionButton.isEnabled = true
            }
        }
  
        DataService.instance.REF_TRIPS.observe(.childRemoved) { (tripSnapshot) in
            if tripSnapshot.key == userId {
                
                self.removeOverlay()
                self.removeUserPin()
                self.removeDestinationPin()
                self.centerMapOnUserLocation()

                
            }
            else if tripSnapshot.childSnapshot(forPath: kDRIVERID).value as! String == userId {
                self.removeOverlay()
                self.removeUserPin()
                self.removeDestinationPin()
                self.centerMapOnUserLocation()
                self.actionButton.isHidden = true
            }
        }
        
        // Find trip belongs to driver
        DataService.instance.fetchTrip(forDriver: userId) { (trip) in
            if let trip = trip {
                
                let pickupMapItem = self.createMapItem(fromDictionary: trip, key: kPICKUP_COORDINATE)
                
                let passengerId = trip[kPASSENGER] as! String
                
                //Create route to passenger
                 let passengerAnnotation =  PassengerAnnotation(coordinate: pickupMapItem.placemark.coordinate,key: passengerId)
             
                self.mapView.addAnnotation(passengerAnnotation)
                self.createRoute(fromMapItem: nil, toMapItem: pickupMapItem)
                self.setRegionForMonitoring(forAnnotationType: .pickUp, withCoordinate: pickupMapItem.placemark.coordinate)
                
                self.buttonAction = .getDirectionToPassenger
                self.actionButton.setTitle(kGET_DIRECTIONS, for: .normal)
                self.actionButton.isHidden = false
               
            }
        }
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
    
    
        
    @IBAction func actionButton(_ sender: Any) {
        actionButton.animateButton(shouldLoad: true, withMessage: nil)
        if Auth.auth().currentUser?.uid != nil {
            buttonSelector(forAction: buttonAction)
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
    
    // NEED TO TEST THIS FUNCTION IN REAL TIME
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let driverId = Auth.auth().currentUser?.uid else {return}
        
        DataService.instance.driverIsOnTrip(driverId: driverId) { (isOnTrip, driverId, tripId) in
            if isOnTrip {
                if region.identifier == kPICKUP {
                    self.buttonAction = .startTrip
                    print("Driver Entered pickup region!")
                    self.actionButton.setTitle(kSTART_TRIP, for: .normal)
               
                } else if region.identifier == kDESTINATION {
                    self.buttonAction = .endTrip
                    self.actionButton.setTitle(kEND_TRIP, for: .normal)
                }
             }
        }
     }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
         guard let driverId = Auth.auth().currentUser?.uid else {return}
        DataService.instance.driverIsOnTrip(driverId: driverId) {
            (isOnTrip, driverId, tripId) in
            
            if isOnTrip == true {
                
                if region.identifier == kPICKUP {
                    // Call an action on the button that will load directions to passenger pickup
                    self.buttonAction = .getDirectionToPassenger
                    self.actionButton.setTitle(kGET_DIRECTIONS, for: .normal)
                }
                else if region.identifier == kDESTINATION
                {
                    // Call an action on the button that will load directions to destination
                    self.buttonAction = .getDirectionToDestination
                    self.actionButton.setTitle(kGET_DIRECTIONS, for: .normal)
                   
                }
            }
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
                        .driverIsOnTrip(driverId: id, handler: { (isOnTrip, driverKey, tripKey) in
                            if isOnTrip {
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
            
            annotationView!.image = UIImage(named: "destination_pin")
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
    
    func buttonSelector(forAction action: buttonActionForDrivers) {
        guard let userId = Auth.auth().currentUser?.uid else {return}
        
        switch action {
            
        case .startTrip:
            DataService.instance.driverIsOnTrip(driverId: userId) { (isOnTrip, driverId, tripId) in
                if isOnTrip {
                self.removeOverlay()
                    DataService.instance.REF_TRIPS.child(tripId!).updateChildValues([kTRIP_ON_PROGRESS: true])
                    
                    DataService.instance.fetchTrip(forDriver: driverId!, completion: { (tripDict) in
                        if let tripDict = tripDict {
                            let destinationMapItem = self.createMapItem(fromDictionary: tripDict, key: kDESTINATION_COORDINTE)
                            
                            self.dropPinFor(placemark: destinationMapItem.placemark)
                             self.createRoute(fromMapItem: nil, toMapItem: destinationMapItem)
                            self.setRegionForMonitoring(forAnnotationType: .destination, withCoordinate: destinationMapItem.placemark.coordinate)
                             self.buttonAction = .getDirectionToDestination
                            self.actionButton.setTitle(kGET_DIRECTIONS, for: .normal)
                        }
                    })
                }
            }
        
        case .cancelTrip:
            DataService.instance.driverIsOnTrip(driverId:userId) {
                (isOnTrip, driverId, tripId) in
                self.removeOverlay()
                self.removeDestinationPin()
                self.centerMapOnUserLocation()
            }
      
        case .endTrip:
            DataService.instance.driverIsOnTrip(driverId: userId) {(isOnTrip, driverId, tripId) in
                if isOnTrip{
                    DataService.instance.cancelTrip(withPassengerId: tripId!, forDriverId: driverId!)
                    self.removeOverlay()
                    self.removeUserPin()
                    self.removeDestinationPin()
                    self.centerMapOnUserLocation()
                   
                    
                }
            }
        case .getDirectionToPassenger:
            DataService.instance.driverIsOnTrip(driverId: userId) { (isOnTrip, driverId, TripId) in
                if isOnTrip{
                    DataService.instance.fetchTrip(forDriver: userId, completion: { (tripDict) in
                        if let tripDict = tripDict {
                            let pickupMapItem = self.createMapItem(fromDictionary: tripDict, key: kPICKUP_COORDINATE)
                            pickupMapItem.name = "Passenger Pickup Point"
                            pickupMapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
                        }
                    })
                }
            }

        case .getDirectionToDestination:
            DataService.instance.driverIsOnTrip(driverId: userId) { (isOnTrip, driverId, TripId) in
                if isOnTrip{
                    DataService.instance.fetchTrip(forDriver: userId, completion: { (tripDict) in
                        if let tripDict = tripDict {
                            let destinationMapItem = self.createMapItem(fromDictionary: tripDict, key: kDESTINATION_COORDINTE)
                            destinationMapItem.name = "Destination Point"
                            destinationMapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
                        }
                    })
                }
            }
            
        }
    }

 

    
    func setRegionForMonitoring(forAnnotationType annotation: AnnotationType, withCoordinate coordinate: CLLocationCoordinate2D){
        
        if annotation == .pickUp {
            let pickUpRegion = CLCircularRegion(center: coordinate, radius: 100, identifier: kPICKUP)
            locationManager.startMonitoring(for: pickUpRegion)
        }
        else if annotation == .destination  {
            let destionationRegion = CLCircularRegion(center: coordinate, radius: 100, identifier: kDESTINATION)
            locationManager.startMonitoring(for: destionationRegion)
        }
    }
    
    func createRoute(fromMapItem source: MKMapItem?, toMapItem destination: MKMapItem) {
        let directionRequest = MKDirections.Request()
        
        if let source = source {
            directionRequest.source = source
        }else{
            directionRequest.source = MKMapItem.forCurrentLocation()
        }
        directionRequest.destination = destination
        directionRequest.transportType = .automobile
        
        let direction = MKDirections(request: directionRequest)
        direction.calculate { (response, error) in
            guard error == nil else {return}
            
            if let response = response {
                
                self.route = response.routes[0]
                self.mapView.addOverlay(self.route.polyline)
                
                self.zoom(toFitAnnotationsFromMapView: self.mapView, forActiveTripWithDriver: false, withKey: nil)
                
            }
        }
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer()
        }
        
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.lineWidth = 3.0
        renderer.strokeColor = UIColor(red: 161/255, green: 31/255, blue: 53/255, alpha: 1)
        return renderer
    }
    
    func createMapItem(fromDictionary dict: [String:Any], key:String)-> MKMapItem{
        let coordinateArray = dict[key] as! [CLLocationDegrees]
        let coordinate = CLLocationCoordinate2D(latitude: coordinateArray[0], longitude: coordinateArray[1])
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        
        return mapItem
        
    }
    // NOT SURE IF THIS BELOWS HERE
     func dropPinFor(passengerLocation: CLLocationCoordinate2D?) {
        // dorp in passenger annotation
        if let passengerCoordinate = locationManager.location?.coordinate,
            let userId = Auth.auth().currentUser?.uid{
            let passengerAnnotation = PassengerAnnotation(coordinate: passengerCoordinate, key: userId)
            mapView.addAnnotation(passengerAnnotation)
        }
    }
    func dropPinFor(placemark: MKPlacemark){
        
        removeDestinationPin()
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        mapView.addAnnotation(annotation)
    }
    
    func removeDriverPin() {
        for annotation in mapView.annotations {
            if let annotation = annotation as? DriverAnnotation {
                mapView.removeAnnotation(annotation)
            }
        }
    }
    
   func removeOverlay() {
        
        for overlay in mapView.overlays {
            if overlay is MKPolyline {
                mapView.removeOverlay(overlay)
            }
        }
    }
    
    func removeUserPin() {
        for annotation in mapView.annotations {
            if let annotation = annotation as? PassengerAnnotation {
                mapView.removeAnnotation(annotation)
            }
        }
    }
    
    func removeDestinationPin() {
        for annotation in mapView.annotations {
            if annotation.isKind(of: MKPointAnnotation.self) {
                mapView.removeAnnotation(annotation)
            }
        }
    }
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

