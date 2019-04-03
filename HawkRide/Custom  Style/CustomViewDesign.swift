//
//  CustomViewDesign.swift
//  Hawk Ride
//
//  Created by Gregory Jones on 3/12/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//

import UIKit

class CustomViewDesign: UIView {
    
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
        layer.borderColor = UIColor(red: 161/255, green: 31/255, blue: 53/255, alpha: 1.0).cgColor
        backgroundColor = Colors.redBackground
       // layer.shadowColor = UIColor.white.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 3
       layer.cornerRadius  = frame.size.height/4
        
      
    }
    
}
