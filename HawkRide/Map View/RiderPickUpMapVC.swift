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
       
      
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
       setupAnnotation(location: location)
        drawRoute(location: location)
        
    }
   
    @IBAction func requestButton(_ sender: RequestCustomButton) {
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
        if let annotation = annotation as? PassengerAnnotation {
            let identifier = "passenger"
            var view: MKAnnotationView
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.image = UIImage(named: "destinationAnnotation")
            return view
        } else if let annotation = annotation as? MKPointAnnotation {
            let identifier = "destination"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }else {
                annotationView?.annotation = annotation
            }
            annotationView?.image = UIImage(named: "destinationAnnotation")
            return annotationView
        }
        return nil
    }
    
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
            //        default:  //Default will never be executed
            //            break
        }
    }
    
}

extension RiderPickUpMapVC {
    
    func buttonSelector(forAction action: ButtonAction) {
        guard let userId = Auth.auth().currentUser?.uid
            else {return}
        
        switch action {
        case .requestTrip:
            DataService.instance.createTrip()
        }
    }
    
    
}



    

