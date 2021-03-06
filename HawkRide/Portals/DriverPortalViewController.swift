//
//  DriverPortalViewController.swift
//  HawkRide
//
//  Created by Gregory Jones on 2/6/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//

import UIKit

class DriverPortalViewController: UIViewController {
    
    

    @IBOutlet weak var DriverSignInButton: SAButton!
    @IBOutlet weak var DriverRegisterButton: SAButtonPart2!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /** Customizing the navigation controller bar */
        
        self.navigationItem.backBarButtonItem?.title = ""  // Changing the title of the navigation item
        self.navigationItem.backBarButtonItem = UIBarButtonItem()  // Enabling the back button
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default) // Allowing the background image to display over the navigation bar
        self.navigationController?.navigationBar.shadowImage = UIImage() // Shadowing the navigation bar under the image
        self.navigationController?.navigationBar.isTranslucent = true  // Navigation bar becomes transparent
        self.navigationController?.view.backgroundColor = .clear
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.white // Changing the color of the navigation item
        
       
        
    }
    



}
