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


class RiderPickUpMapVC: UIViewController {
   
    //MARK: - Properties
   
    @IBOutlet weak var mapView: MKMapView!
    var sidebarView: SidebarViewRider!
    var blackScreen: UIView!
    var locationManager = CLLocationManager()
    let regionInMeters: Double = 1800
    @IBOutlet weak var requestButton: RoundedShadowButton!
    
    //Coordinates of Locations
    var currentLocationLatitude = CLLocationDegrees()
    var currentLocationLongitude = CLLocationDegrees()
    var location = Location()
  
    var route: MKRoute!
    
    override func viewDidLoad() {
       super.viewDidLoad()
        mapView.delegate = self
       
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkLocationServices()
        
       //  self.userLocationAnnotationView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorization()
        setupAnnotation(location: location)
        drawRoute(location: location)
        
    }
   
    @IBAction func requestButtonWasPressed(_sender: Any) {
        requestButton.animateButton(shouldLoad: true, withMessage: nil)
        
    }
    
}
    
extension RiderPickUpMapVC: CLLocationManagerDelegate, MKMapViewDelegate {
    
  
    
    func setupAnnotation(location: Location) {
        let riderLocation = CLLocationCoordinate2D(latitude: currentLocationLatitude, longitude: currentLocationLongitude)
        
        let riderAnnotation = PassengerAnnotation(coordinate: riderLocation)
        
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
   
   
 /*  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
         let renderer = MKPolylineRenderer(overlay: self.route.polyline)
                renderer.lineWidth = 3.0
                renderer.alpha = 0.5
                renderer.strokeColor = UIColor.black
    
        
        return renderer
    } */
    

   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            let location = locations.first
            
            currentLocationLatitude = (location?.coordinate.latitude)!
            currentLocationLongitude = (location?.coordinate.longitude)!
            
            let coordinateRegion = MKCoordinateRegion(center: (location?.coordinate)!, latitudinalMeters: regionInMeters * 2.0 , longitudinalMeters: regionInMeters * 2.0 ) // we have to multiply the regionradius by 2.0 because it's only one direction but we want 1000 meters in both directions;we're gonna set how wide we want the radius to be around the center location
            mapView.setRegion(coordinateRegion, animated: true) //to set it
            
            locationManager.stopUpdatingLocation()
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
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedAlways
        {
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .follow
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

    

