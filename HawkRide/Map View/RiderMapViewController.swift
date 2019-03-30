//
//  RideMapViewController.swift
//  Hawk Ride
//
//  Created by Gregory Jones on 2/26/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import GeoFire
import Alamofire
import SwiftyJSON
import GooglePlaces

class RiderMapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    
    // MARK: - Properties
    var sidebarView: SidebarViewRider!
    var blackScreen: UIView!
    var locationManager = CLLocationManager()
    var tableView = UITableView()
    @IBOutlet  var mapView: GMSMapView!
    public var location = CLLocationManager()
    
    
 

    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        customNavigationBar()
        initializeTheLocationManager()
        setupMapView()
        setupMenuButton()
        setupSideBarView()
        setupBlackScreen()
     
     
      
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
    func setupMapView() {
        self.mapView.isMyLocationEnabled = true
        self.mapView.mapStyle(withFilename: "bright", andType: "json");
    }
    
    func initializeTheLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: - Location Manager Delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locationManager.location?.coordinate
        
        cameraMoveToLocation(toLocation: location)
    }
    
    func cameraMoveToLocation(toLocation: CLLocationCoordinate2D?) {
        if toLocation != nil {
            mapView.camera = GMSCameraPosition.camera(withTarget: toLocation!, zoom: 16)
        }
    }
 
    //MARK: function for create a marker pin on map
    
    func createMarker(titleMarker: String, iconMarker: UIImage, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
        marker.title = titleMarker
        marker.icon = iconMarker
        marker.map = mapView
    }
    
    //MARK - GMSMAPViewDelegate
    
    func mapView(_mapView: GMSMapView, willMove gesture: Bool) {
        mapView.isMyLocationEnabled = true
        
        if(gesture) {
            mapView.selectedMarker = nil
            
        }
    }
    
    func mapView(_mapView: GMSMapView, didTap amrker: GMSMarker) -> Bool {
      mapView.isMyLocationEnabled = true
        return false
    }
    
    func mapView(_mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("COORDINATE \(coordinate)") // when you tapped coordinate
    }
    
    //MARK: this is function for create direction path, from start location to end destination
    
  

    //MARK: SHOW DIRECTION WITH CLICK OF BUTTON
    
   
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
        sidebarView.delegate=self
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
    

/* Check the Map Style for Google Maps */

extension GMSMapView {
    func mapStyle(withFilename name: String, andType type: String) {
        do  {
            if let styleURL = Bundle.main.url(forResource: name, withExtension: type) {
                self.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            }  else {
                NSLog("Unable to find style.join")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    }
}


