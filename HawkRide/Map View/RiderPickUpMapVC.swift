//
//  RiderPickUpMap.swift
//  Hawk Ride
//
//  Created by Gregory Jones on 4/3/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import CoreData
import Firebase


class RiderPickUpMapVC: UIViewController {
   
    //MARK: - Properties
   
    @IBOutlet weak var mapView: MKMapView!
    var sidebarView: SidebarViewRider!
    var blackScreen: UIView!
    var locationManager = CLLocationManager()
    let regionInMeters: Double = 1800
    @IBOutlet weak var RequestButton: RequestCustomButton!
    @IBOutlet weak var CancelButton: RequestCustomButton!
    //Coordinates of Locations
    var currentLocationLatitude = CLLocationDegrees()
    var currentLocationLongitude = CLLocationDegrees()
    var location = Location()
    var currentUserId : String?
   
  
    var route: MKRoute!
    
    var buttonAction: ButtonAction = .requestTrip
    
    override func viewDidLoad() {
       super.viewDidLoad()
        mapView.delegate = self
        locationManager = CLLocationManager()
        locationManager.delegate = self
        checkLocationAuthStatus()
        currentUserId = Auth.auth().currentUser?.uid
        
        
  }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupAnnotation(location: location)
        drawRoute(location: location)
        
        guard let userId = Auth.auth().currentUser?.uid else
        {return}
        
        DataService.instance.REF_TRIPS.observe(.childRemoved) {(tripSnapshot) in
            if tripSnapshot.key == userId {
               self.removeOverlay()
               self.removeUserPin()
               self.removeDestinationPin()
               self.RequestButton.isEnabled = true
               
                
            } else {
               
                self.RequestButton.animateButton(shouldLoad: false, withMessage: "Request Hawk Ride")
                 self.centerMapOnUserLocation()
            }
            
        }
        
        connectUserAndDriverForTrip()
        
}
    
   
    @IBAction func requestButton(_ sender: RequestCustomButton) {
       RequestButton.animateButton(shouldLoad: true, withMessage: nil)
        if Auth.auth().currentUser?.uid != nil {
            buttonSelector(forAction: buttonAction)
            
        }else {
            let vc = UIStoryboard.init(name: "Login", bundle: Bundle.main).instantiateInitialViewController() as! HawkRiderSignInViewController
            present(vc, animated: true)
        }
    }
    
}

extension RiderPickUpMapVC: CLLocationManagerDelegate, MKMapViewDelegate {
    
      func setupAnnotation(location: Location) {
        
         let passengerId = kPASSENGER
       
         let riderLocation = CLLocationCoordinate2D(latitude: currentLocationLatitude, longitude: currentLocationLongitude)
        
        
        let riderAnnotation = PassengerAnnotation(coordinate: riderLocation, key: passengerId)
        
        
        mapView.addAnnotation(riderAnnotation)
        
        let destinationLocation = location.coordinate!
        let annotation = MKPointAnnotation()
        annotation.coordinate = destinationLocation
      
        mapView.addAnnotation(annotation)
   
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
    
    // Draw a route for the passenger request location and current locaiton //
    func drawRoute(location: Location) {
        
        let sourceLocation = MKMapItem.forCurrentLocation()
        let destinationLocation = location.coordinate!
        
        let sourcePlacemark = sourceLocation
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        let sourceMapItem = sourcePlacemark
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        
        let request = MKDirections.Request()
        request.source = sourceMapItem
        request.destination = destinationMapItem
        request.transportType = MKDirectionsTransportType.automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculate { (response, error) in
            guard let response = response else {
                print(error.debugDescription)
                return
            }
            self.route = response.routes[0]
            
            self.mapView.addOverlay(self.route.polyline)
        }
        
     
    }
    func createRoute(forOriginMapItem originMapItem: MKMapItem?, withDestinationMapItem destinationMapItem: MKMapItem) {
       
        let request = MKDirections.Request()
        
        if originMapItem == nil
        {
            request.source = MKMapItem.forCurrentLocation()
        }
        else
        {
            request.source = originMapItem
        }
        
        request.destination = destinationMapItem
        request.transportType = MKDirectionsTransportType.automobile
        request.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: request)
        
        directions.calculate { (response, error) in
            
            guard let response = response else {
                
              
                return
            }
            self.route = response.routes[0]
            
            self.mapView.addOverlay(self.route!.polyline)
            
            self.zoom(toFitAnnotationsFromMapView: self.mapView, forActiveTripWithDriver: false, withKey: nil)
            
          
        }
        
        
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer()
        }
        
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.lineWidth = 3.0
        renderer.strokeColor = UIColor(red: 161/255, green: 31/255, blue: 53/255, alpha: 1)
       return renderer
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthStatus()
        
        if status == .authorizedAlways {
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .follow
        }
    }
    
    func checkLocationAuthStatus(){
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
            
        } else {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let id = Auth.auth().currentUser?.uid {
            DataService.instance.updateUserLocation(userID: id, withCoordinate: userLocation.coordinate)
            
            DataService.instance.passengerIsOnTrip(passengerId: id, handler: {
                (isOnTrip, driverKey, tripKey) in
                if isOnTrip{
                    self.zoom(toFitAnnotationsFromMapView: self.mapView, forActiveTripWithDriver: true, withKey: driverKey)
                } else {
                    self.centerMapOnUserLocation()
                }
            })
        }
     }
  }

extension RiderPickUpMapVC: SidebarViewRiderDelegate {
    
    /* Adding the rows to the side bar */
    func sidebarDidSelectRow(row: Row) {
        blackScreen.isHidden=true
        blackScreen.frame=self.view.bounds
        UIView.animate(withDuration: 0.3) {
            self.sidebarView.frame=CGRect(x: 0, y: 0, width: 0, height: self.sidebarView.frame.height)
        }
        switch row {
        case .editProfile:
            let controller = EditProfileController()
            present(UINavigationController(rootViewController:controller), animated: true, completion: nil)
        case .rideHistory:
            print("Ride History")
        case .becomeAHawkDriver:
            print("Become a Hawk Driver")
        case .help:
            print("Help")
        case .settings:
            print("Settings")
        case .logOut:
            print("Log out")
        case .none:
            break
           
        }
    }
    
}

extension RiderPickUpMapVC {
    
    func buttonSelector(forAction action: ButtonAction) {
        guard let userId = Auth.auth().currentUser?.uid
            else {return}
        
        switch action {
        case .requestTrip:
        RequestButton.animateButton(shouldLoad: true, withMessage: nil)
        DataService.instance.createTrip()
            
        case .cancelTrip:
            DataService.instance.passengerIsOnTrip(passengerId: userId) { (isOnTrip, driverId, tripId) in
                self.removeDestinationPin()
                self.removeOverlay()
                self.removeDriverPin()
                self.centerMapOnUserLocation()
                DataService.instance.cancelTrip(withPassengerId: userId, forDriverId: driverId!)
                self.buttonAction = .requestTrip
                self.RequestButton.setTitle("Request Hawk Ride", for: .normal)
            
            }
        } 
    }

    func createMapItem(fromDictionary dict:[String: Any], key: String)-> MKMapItem{
        let coordinateArray = dict[key] as! [CLLocationDegrees]
        let coordinate = CLLocationCoordinate2D(latitude: coordinateArray[0], longitude: coordinateArray[1])
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        
        return mapItem
    }
    
  func dropPinFor(placemark: MKPlacemark){
        
        removeDestinationPin()
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        mapView.addAnnotation(annotation)
    }
    
    
    func removeDestinationPin() {
        
        for annotation in mapView.annotations {
            if annotation.isKind(of: MKPointAnnotation.self) {
                mapView.removeAnnotation(annotation)
            }
        }
    }
    
    func removeDriverPin() {
        
        for annotation in mapView.annotations {
            if let annotation = annotation as? DriverAnnotation {
                mapView.removeAnnotation(annotation)
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
    
       func removeOverlay(){
        
        for overlay in mapView.overlays {
            if overlay is MKPolyline {
                mapView.removeOverlay(overlay)
            }
        }
    }
    
    
    func centerMapOnUserLocation(){
        let regionRadious: CLLocationDistance = 2000
        let coordinateRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: regionRadious, longitudinalMeters: regionRadious)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    func connectUserAndDriverForTrip() {
        guard let userId = Auth.auth().currentUser?.uid else{return}
        
        DataService.instance.userIsDriver(userId: userId) { (isDriver) in
            if !isDriver {
                DataService.instance.REF_TRIPS.child(userId).observe(.value, with: { (tripSnapshot) in
                    
                    guard let tripDict = tripSnapshot.value as? [String:Any] else {return}
                    if tripDict[kTRIP_IS_ACCEPTED] as! Bool {
                        self.removeOverlay()
                        self.removeUserPin()
                        self.removeDriverPin()
                        
                        let driverId = tripDict[kDRIVERID] as! String
                        
                        let pickupMapItem = self.createMapItem(fromDictionary: tripDict, key: kPICKUP_COORDINATE)
                        
                        DataService.instance.REF_DRIVERS.child(driverId).observeSingleEvent(of: .value, with: { (driverSnapshot) in
                            
                            if let driverSnapshot = driverSnapshot.value as? [String:Any] {
                                
                                let driverMapItem = self.createMapItem(fromDictionary: driverSnapshot, key: kCOORDINATES)
                                
                                // create annotations and route
                                let passengerAnnotation = PassengerAnnotation(coordinate: pickupMapItem.placemark.coordinate, key: userId)
                                let driverAnnotation = DriverAnnotation(coordinate: driverMapItem.placemark.coordinate, driverID: driverId)
                                
                                self.mapView.addAnnotations([passengerAnnotation,driverAnnotation])
                                self.createRoute(forOriginMapItem: driverMapItem, withDestinationMapItem: pickupMapItem)
                                
                                DispatchQueue.main.async {
                                    self.RequestButton.animateButton(shouldLoad: false, withMessage: kCANCEL_TRIP)
                                    self.buttonAction = .cancelTrip
                                    
                                    // Optional
                                    /*self.RequestButton.animateButton(shouldLoad: false, withMessage: kDRIVING_COMING) */
                                }
                            }
                        })
                        
                        if tripDict[kTRIP_ON_PROGRESS] as? Bool == true {
                            self.removeOverlay()
                            self.removeUserPin()
                            self.removeDriverPin()
                            
                            let destinationMapItem = self.createMapItem(fromDictionary: tripDict, key: kDESTINATION_COORDINTE)
                            
                            self.dropPinFor(placemark: destinationMapItem.placemark)
                            self.createRoute(forOriginMapItem: nil, withDestinationMapItem: destinationMapItem)
                            
                            self.RequestButton.setTitle(kON_TRIP, for: .normal)
                            self.RequestButton.isEnabled = false
                            
                        }
                        
                    }
                    
                })
            }
        }
    }
    
    
    
}



    

