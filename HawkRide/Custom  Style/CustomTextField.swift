//
//  CustomTextField.swift
//  Hawk Ride
//
//  Created by Gregory Jones on 3/25/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//
import UIKit
class CustomTextField: UITextField {
    
    /** Convenince initializer must delegate across not up
     * This method init and call super.init to faciliate that
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewDesign()
    }
    
    // For storyboard
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViewDesign()
    }
    
    /* A method that creates the destination view holder
     *The view holder holds the current destination and search destination text field
     */
    func setupViewDesign() {
        layer.borderWidth = 0.0
        layer.borderWidth = 0.0
        layer.borderColor = UIColor(red: 216/255, green: 216/255, blue:216/255, alpha: 1.0).cgColor
       
        
        
        
    }
    
}
