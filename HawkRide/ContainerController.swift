//
//  ContainerController.swift
//  Hawk Ride
//
//  Created by Gregory Jones on 3/11/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//

import UIKit

class ContainerController: UIViewController {
    
    // MARK: = Properties
    
    var menuController: UIViewController!
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Handlers
    
    func configureMenuController() {
        if menuController == nil {
            // add our menu controller here
            menuController = MenuController()
            view.insertSubview(menuController.view, at:0)
            addChild(menuController)
            menuController.didMove(toParent:self)
            print("Did add Menu Controller")
        }
        
    }
    
}

extension ContainerController: RiderMapViewControllerDelegate {
    
    func handleMenuToggle() {
        configureMenuController()
    }
    
}
