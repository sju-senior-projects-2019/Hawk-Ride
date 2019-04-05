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
    let regionInMeters: Double = 1500
    
    //Coordinates of Locations
    var currentLocationLatitude = CLLocationDegrees()
    var currentLocationLongitude = CLLocationDegrees()
    var location = Location()
    
    var routeDistance = Double() //Distance of Route
    var routeETA = Double() //Travel Time of Route
    
    override func viewDidLoad() {
       super.viewDidLoad()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkLocationServices()
        showRouteOnMap(location: location)
        self.userLocationAnnotationView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorization()
    }
}
    
extension RiderPickUpMapVC: CLLocationManagerDelegate, MKMapViewDelegate {
    
    func showRouteOnMap(location: Location) {
        let sourceLocation = CLLocationCoordinate2D(latitude: currentLocationLatitude, longitude: currentLocationLongitude)
        let destinationLocation = location.coordinate!
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let sourceAnnotation = CustomPointAnnotation()
        sourceAnnotation.title = "Pick Up Location"
        sourceAnnotation.subtitle = "Pick Up Location"
        sourceAnnotation.pinCustomImageName = "pickup"
        
        if let location = sourcePlacemark.location  {
            sourceAnnotation.coordinate = location.coordinate
            
        }
        
        let destinationAnnotation = CustomPointAnnotation()
        destinationAnnotation.title = "Drop Off Location"
        destinationAnnotation.subtitle = "Drop Off Location"
        destinationAnnotation.pinCustomImageName = "destination"
        
        // Custom Annotation
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        self.mapView.showAnnotations([sourceAnnotation, destinationAnnotation], animated: true)
        
        let directionRequest = MKDirections.Request() // The start and end points of a route, along the planned mode of transporation
        
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        let directions  = MKDirections(request: directionRequest)
        
        //
        directions.calculate { (response, error) in
            
            guard let response = response else {
                if let error = error  {
                    print("Error: \(error)")
                }
                return
            }
            
            let route = response.routes[0]
            self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
            
            self.routeDistance = route.distance //distance of route in meters
            self.routeETA = route.expectedTravelTime / 60 //in seconds, so divide by 60
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
        func userLocationAnnotationView() {
            let userLocation = CLLocationCoordinate2D(latitude: currentLocationLatitude, longitude: currentLocationLongitude)
            
            let userPlacemark = MKPlacemark(coordinate: userLocation, addressDictionary: nil)
            
            let userAnnotation = CustomPointAnnotation()
            userAnnotation.pinCustomImageName = "pickup"
            
            if let location = userPlacemark.location {
                userAnnotation.coordinate = location.coordinate
            }
            mapView.showAnnotations([userAnnotation], animated: true)
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            
            renderer.strokeColor = #colorLiteral(red: 0.2980392157, green: 0.631372549, blue: 0.9254901961, alpha: 1)
            renderer.lineWidth = 4.0
            
            return renderer
        }
        
        
        
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
                // centerViewOnUserLocation()
                showRouteOnMap(location: location)
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

    

