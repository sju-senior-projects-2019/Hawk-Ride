//
//  ViewController.swift
//  HawkRide
//
//  Created by Gregory Jones on 1/29/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    

    @IBOutlet weak var HawkRiderButton: SAButton!
    @IBOutlet weak var HawkDriverButton: SAButton!
    @IBOutlet weak var BecomeAHawkDriverButton: SAButtonPart2!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    /* Customizing the navigation bar */
    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Hello", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
    self.navigationItem.backBarButtonItem?.title = ""
    self.navigationItem.backBarButtonItem = UIBarButtonItem()
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    self.navigationController?.navigationBar.shadowImage = UIImage()
    self.navigationController?.navigationBar.isTranslucent = true
    self.navigationController?.view.backgroundColor = .clear
}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
   
}

