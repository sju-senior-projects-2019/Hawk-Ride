//
//  CustomViewDesignTwo.swift
//  Hawk Ride
//
//  Created by Gregory Jones on 3/19/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//
import UIKit

class CustomViewDesignTwo: UIView {
    
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
        layer.borderColor = UIColor(red: 208/255, green: 212/255, blue:217/255, alpha: 1.0).cgColor
        backgroundColor = Colors.whiteBackground
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 0.8
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 5
       
        
        
    }
    
}
