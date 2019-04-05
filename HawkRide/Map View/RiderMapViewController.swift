//
//  RideMapViewController.swift
//  Hawk Ride
//
//  Created by Gregory Jones on 2/26/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import MapKit
import Alamofire
import SwiftyJSON
import CoreData



class RiderMapViewController: UIViewController, MKMapViewDelegate {
    
   
     // MARK: - Properties
    var sidebarView: SidebarViewRider!
    var blackScreen: UIView!
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    let regionInMeters: Double = 1500 //Originally at was 750
    @IBOutlet weak var tableView: UITableView!
    var selectedLocation = Location()
   
    //Coordaintes of Locations
    var currentLocationLatitude = CLLocationDegrees()
    var currentLocationLongitude = CLLocationDegrees()
   
    var routeDistance = Double() //Distance of Route
    var routeETA = Double() //Travel Time of Route

    
    //Location Array
    
    var locations: [Location] = []
  
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        customNavigationBar()
        setupMenuButton()
        setupSideBarView()
        setupBlackScreen()
        setupTableView()
        locations = createArray()
    }
    
    override func viewWillAppear(_ animated: Bool) {
      
    
       
    }
    
   
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = Colors.primarySlateBackground
        tableView.backgroundColor = Colors.primarySlateBackground
    }
    
    func createArray() -> [Location] {
        
        var tempLocations: [Location] = []
        
         let location1 =  Location(title: "LaFarge Residence Center", desc: "Cardinal Ave", coordinate: CLLocationCoordinate2D(latitude: 39.998940, longitude: -75.238962), location: " 2425 Cardinal Ave")
         let location2 =  Location(title: "Sourin Residence Center", desc: "Cardinal Ave", coordinate: CLLocationCoordinate2D(latitude: 39.993307, longitude: -75.240373), location: " 2449 Cardinal Ave")
         let location3 =  Location(title: "McShain Residence Center", desc: "W. City Avenue", coordinate: CLLocationCoordinate2D(latitude: 39.995423, longitude: -75.240397), location: "333 W.City Ave")
         let location4 =  Location(title: "Villiger Residence Center", desc: "Cardinal Ave", coordinate: CLLocationCoordinate2D(latitude: 39.993682, longitude:  -75.240787), location: " 2525 Cardinal Ave")
         let location5 =  Location(title: "Quirk Hall", desc: "Cardinal Ave", coordinate: CLLocationCoordinate2D(latitude: 39.998535, longitude:-75.239560), location: "2449 Cardinal Ave")
         let location6 =  Location(title: "St. Albert's Hall", desc: "Lapsley Lane", coordinate: CLLocationCoordinate2D(latitude: 40.002363, longitude: -75.240681), location: "40 Lapsley Lane")
         let location7 =  Location(title: "Xaiver Hall", desc: "Lapsley Lane", coordinate: CLLocationCoordinate2D(latitude: 39.996367, longitude: -75.240180), location: "30 Lapsley Lane")
         let location8 =  Location(title: "Moore Hall", desc: " Overbrook Ave", coordinate: CLLocationCoordinate2D(latitude: 39.991035, longitude: -75.247312), location: "6051 Overbrook Ave")
         let location9 =  Location(title: "Ashwood Apartments", desc: "Overbrook Ave", coordinate: CLLocationCoordinate2D(latitude: 39.990279, longitude: -75.248051),  location: "6050 Overbrook Ave")
         let location10 = Location(title: "Lannon Apartments", desc: "City Ave", coordinate: CLLocationCoordinate2D(latitude: 39.997343, longitude: -75.234780), location: "5320 City Ave")
         let location11 = Location(title: "Pennbrook Apartments", desc: "North 63rd Street", coordinate: CLLocationCoordinate2D(latitude: 39.989089, longitude:  -75.250746),  location: "2120-2134 North 63rd St")
         let location12 = Location(title: "Rashford Apartments", desc: "City ave", coordinate: CLLocationCoordinate2D(latitude: 39.998940, longitude: -75.238962),  location: "5200 City Ave")
         let location13 = Location(title: "Merion Gardens Apartments", desc: "City Ave", coordinate: CLLocationCoordinate2D(latitude: 39.990726, longitude: -75.251295),  location: "701 City Ave")
         let location14 = Location(title: "Townhouses", desc: "Cardinal Ave", coordinate: CLLocationCoordinate2D(latitude: 39.998940, longitude: -75.238962), location: " 2425 Cardinal Ave")
         let location15 = Location(title: "Hogan", desc: "Lapsley Lane", coordinate: CLLocationCoordinate2D(latitude: 39.998613, longitude: -75.239587), location: " 81 Lapsley Lane")
        
        
        
        tempLocations.append(location1)
        tempLocations.append(location2)
        tempLocations.append(location3)
        tempLocations.append(location4)
        tempLocations.append(location5)
        tempLocations.append(location6)
        tempLocations.append(location7)
        tempLocations.append(location8)
        tempLocations.append(location9)
        tempLocations.append(location10)
        tempLocations.append(location11)
        tempLocations.append(location12)
        tempLocations.append(location13)
        tempLocations.append(location14)
        tempLocations.append(location15)
       
       
        
        return tempLocations
    }
    
    /* Hint:
   This function does not work in the rider map view controller - it works for the next view controller which is setDropOffLocationVc
    */
    func customNavigationBar() {
        /** Customizing the navigation controller bar */
       
        self.navigationItem.backBarButtonItem?.title = "" // Changing the title of the navigation item
        self.navigationItem.backBarButtonItem = UIBarButtonItem() // Enabling the back button
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default) // Allowing the background image to display over the navigation bar
        self.navigationController?.navigationBar.shadowImage = UIImage() // Shadowing the navigation bar under the image
        self.navigationController?.navigationBar.isTranslucent = true // Navigation bar becomes transparent
        self.navigationController?.view.backgroundColor = .clear
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.black // Changing the color of the navigation item
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
    
    func showRouteOnMap(location: Location) {
       
     let sourceLocation = CLLocationCoordinate2D(latitude: currentLocationLatitude, longitude: currentLocationLongitude)
     let destinationLocation = location.coordinate
        
     let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
     let destinationPlacemark = MKPlacemark(coordinate: destinationLocation ?? CLLocationCoordinate2D(), addressDictionary: nil)
        
    let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
    let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
   
        let sourceAnnotation = CustomPointAnnotation()
        sourceAnnotation.title = "Pick Up Location"
        sourceAnnotation.subtitle = "Pick Up Location"
    
        sourceAnnotation.pinCustomImageName = "pickuppin"
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
            
        }
        
        let destinationAnnotation =  CustomPointAnnotation()
        destinationAnnotation.title = "Drop Off Location"
        destinationAnnotation.subtitle = "Drop Off Location"
        destinationAnnotation.pinCustomImageName = "destinationpin"
        
        //custom annotation
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        //
        self.mapView.showAnnotations([sourceAnnotation, destinationAnnotation], animated: true)
        //
        let directionRequest = MKDirections.Request() //The start and end points of a route, along with the planned mode of transportation.
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        //
        directions.calculate { (response, error) in
            
            guard let response = response else {
                if let error = error {
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
    
        // UserlocationAnnoationView
        let userLocation = CLLocationCoordinate2D(latitude: currentLocationLatitude, longitude: currentLocationLongitude)
        let userPlaceMark = MKPlacemark(coordinate: userLocation, addressDictionary: nil)
        
        let userAnnotation =  CustomPointAnnotation()
        userAnnotation.pinCustomImageName = "pickuppin"
        
        if let location = userPlaceMark.location {
            userAnnotation.coordinate = location.coordinate
        }
        
        mapView.showAnnotations([userAnnotation], animated: true)
        
      }
    
  
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? { //custom annotation
        
        let reuseIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        if let customPointAnnotation = annotation as? CustomPointAnnotation {
            annotationView?.image = UIImage(named: customPointAnnotation.pinCustomImageName)
        }
        
        return annotationView
    }
        
    
  

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
        sidebarView=SidebarViewRider(frame: CGRect(x: 0, y: 0, width: 0, height: self.view.frame.height))
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
//MARK: - Navigation

extension RiderMapViewController: CLLocationManagerDelegate {
 func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedAlways
        {
           mapView.showsUserLocation = true
           mapView.userTrackingMode = .follow
        }
 }
    
}

extension RiderMapViewController: SidebarViewRiderDelegate {
   
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

extension RiderMapViewController: UITableViewDataSource, UITableViewDelegate {
   
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let location = locations[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationcell", for:indexPath) as! LocationTableViewCell
        
        cell.setLocation(location: location)
       
       return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedLocation = locations[indexPath.row]
        performSegue(withIdentifier: "goToRiderPickUp", sender: self)
}
   
    
        /*showRouteOnMap(location: selectedLocation)
        let riderPickUpMapVC = RiderPickUpMapVC()
        riderPickUpMapVC.location = selectedLocation
        self.navigationController?.pushViewController(riderPickUpMapVC, animated: true)
        performSegue(withIdentifier: "detailView", sender: selectedLocation) */
 
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToRiderPickUp" {
            if let viewController = segue.destination as? RiderPickUpMapVC {
                viewController.location = selectedLocation
    
            }
        }
    }
       
 func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        return CGFloat(85)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
   
        if(indexPath.row % 2 == 0) {
            cell.backgroundColor = Colors.primarySlateBackground
        }
        else
        {
            cell.backgroundColor = Colors.primaryBlueBackground
        }
    }
    


}
