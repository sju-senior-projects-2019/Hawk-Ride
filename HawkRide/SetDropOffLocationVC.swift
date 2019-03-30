//
//  SetDropOffLocationVC.swift
//  Hawk Ride
//
//  Created by Gregory Jones on 3/19/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces


class SetDropOffLocationVC: UIViewController {
  
  
    
  
    // Core Data Objects
   var location: [Location] = [
    Location(title: "LaFarge Hall", cllocation: CLLocation(latitude: 39.992853, longitude: -75.239888), regionRadius: 300.0, location: "Cardinal Ave", type: "Dorm Hall", coordinate: CLLocationCoordinate2DMake( 39.992853, -75.239888)) ]
    
   
    
   // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
       
    }
    
   
   
   /* func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationLabel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MapTableViewCell
        cell.locationButton.tag = indexPath.row
        cell.locationButton.addTarget(self, action: Selector("tapDidNavi"), for: .touchUpInside)
        
        return cell
    } */
}
class LocationButton: UIButton {
    
    public var location : Location
    
    init(location: Location, frame: CGRect) {
        
        self.location = location
        
        super.init(frame: frame)
        
        setProperties()
      
    }
    
    ///needed for interface builder
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setProperties() {
        //Set properties of button here...
        setTitle("Button Title", for: .normal)
    }
}
    
    // Creating a locationButton
    let locationButton = LocationButton(location: Location(title: "LaFarge Hall", cllocation: CLLocation(latitude: 39.992853, longitude: -75.239888), regionRadius: 300.0, location:"Cardinal Ave", type: "Dorm Hall", coordinate: CLLocationCoordinate2D( latitude: 39.992853, longitude: -75.239888)), frame: CGRect())

  


    
    
    



