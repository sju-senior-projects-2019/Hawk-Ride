//
//  RideMapViewController.swift
//  Hawk Ride
//
//  Created by Gregory Jones on 2/26/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import GeoFire
import SVProgressHUD


class RiderMapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    // MARK: - Properties
    //var map:GMSMapView!
    let locationManager = CLLocationManager()
    var customerLocation = CLLocation()
    var firstUpdate = true
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var RequestRide: SAButtonThree!
    var sidebarView: SidebarViewRider!
    var blackScreen: UIView!
    var marker: GMSMarker? = nil
    var firstzoom = true
    
    
   
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
         mapView = self.view as! GMSMapView?
         self.mapView.delegate = self
         self.view = mapView
        
        /// get user location
        DriverMapViewController.locationManager.delegate = self
        DriverMapViewController.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        DriverMapViewController.locationManager.requestWhenInUseAuthorization()
        DriverMapViewController.locationManager.startUpdatingLocation()
        
        setupMenuButton()
        setupSideBarView()
        setupBlackScreen()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        customerLocation = (manager.location)!
        if firstUpdate {
            firstUpdate = false
            let camera=GMSCameraPosition.camera(withLatitude:(manager.location?.coordinate.latitude)!,
            longitude:
                (manager.location?.coordinate.longitude)!, zoom:
            14)
            mapView.camera = camera
        }
        
        if marker ==  nil {
            marker = GMSMarker()
            marker?.position =
            CLLocationCoordinate2DMake((manager.location?.coordinate.latitude)!,
            (manager.location?.coordinate.longitude)!)
            //marker?.map = mapView
        }
        else{
            CATransaction.begin()
            CATransaction.setAnimationDuration(1.0)
            marker?.position = CLLocationCoordinate2DMake((manager.location?.coordinate.latitude)!,
            (manager.location?.coordinate.longitude)!)
            CATransaction.commit()
        }
        locationManager.stopUpdatingLocation()
    }
 
   
    @IBAction func RequestRideTapped(_ sender: Any) {
      
    
    }
    
    /* Map Customization:
     * Add user's location user coordinates
     * Animating the zoom feature into the map
     * Map Style: Customizing the map design using json file
     * Map Style source: https://snazzymaps.com/style/1261/dark
 */
    func setupMapView() {
        mapView.animate(toLocation: CLLocationCoordinate2DMake(39.995256, -75.241579))
        mapView.animate(toZoom: 15)
        self.mapView.delegate = self
        self.view = mapView
        mapView = self.view as! GMSMapView?
        self.mapView.mapStyle(withFilename: "bright", andType: "json");
    }
  
 /* Hamburger Menu Button
     * Using navigation bar button to integrate the interaction with the menu icon image
     * It calls the function btnMenuAction to interacte with the animation to display the slide menu
     */
    func setupMenuButton() {
        let btnMenu = UIButton(frame: CGRect(x: 0.0, y:0.0, width: 18, height: 14))
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
           self.navigationController?.pushViewController(controller, animated: true)
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




