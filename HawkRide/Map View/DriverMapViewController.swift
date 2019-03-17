//
//  DriverMapViewController.swift
//  Hawk Ride
//
//  Created by Gregory Jones on 2/26/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//

import UIKit
import GoogleMaps
import GeoFire
import CoreLocation
import MapKit



class DriverMapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate{
    
    //MARK: - Properties

    var mapView: GMSMapView!
    static let locationManager = CLLocationManager()
    var sidebarView: SidebarViewDriver!
    var blackScreen: UIView!
    var marker : GMSMarker? = nil
    var firstUpdate = true
    var customerMarker: GMSMarker? = nil

  
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = self.view as! GMSMapView?
        self.mapView.delegate = self
        self.view = mapView
        
        DriverMapViewController.locationManager.delegate = self
        DriverMapViewController.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        DriverMapViewController.locationManager.requestWhenInUseAuthorization()
        DriverMapViewController.locationManager.startUpdatingLocation()
        
        setupMenuButton()
        setupSideBarView()
        setupBlackScreen()
      
}
 
    
    
    
    
    
    //MARK: - Handlers
    
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
        case .logOut:
            print("Log out")
        case .none:
            break
            // default: //Default will never be executed
        }
    }
    
}



    

