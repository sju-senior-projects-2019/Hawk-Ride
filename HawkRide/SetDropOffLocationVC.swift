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


class SetDropOffLocationVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {
  
  
    
    @IBOutlet weak var tableView: UITableView!
    
    // Core Data Objects
   /* var location: [Location] = [
    Location(title: "LaFarge Hall", cllocation: CLLocation(latitude: 39.992853, longitude: -75.239888), regionRadius: 300.0, location: "Cardinal Ave", type: "Dorm Hall", coordinate: CLLocationCoordinate2DMake( 39.992853, -75.239888)) ] */
    
    let locationLabel = [("LaFarge Hall"), ("McShain Hall"), ("Jordan Hall"), ("Sourin Hall"), ("Villiger Hall"), ("Hogan Hall"), ("Quirk Hall"), ("St.Albert's Hall"), ("Sullivan Hall"), ("Xaiver Hall"), ("Moore Hall"), ("Aswhood Hall"), ("Lannon Hall"), ("Pennbrook Hall"), ("Rashford"), ("Merion Gardens Apartments"), ("Townhouses")]
   
    
   // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        setupNavBar()
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.tableView.tableFooterView = UIView()
       // tableView.backgroundColor = [UIColor, clearColor];
      
        //tableView.backgroundView = nil;
        
        
        }
    
    func setupNavBar() {
         let navController = navigationController!
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationLabel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MapTableViewCell
        cell.locationButton.tag = indexPath.row
        cell.locationButton.addTarget(self, action: Selector("tapDidNavi"), for: .touchUpInside)
        
        return cell
    }
    
    @IBAction func tapDidNavi(sender: UIButton) {
        let destination = self.locationLabel[sender.tag]
        
        
    }
}




    
    
    



