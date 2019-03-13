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
    
    func setupViewDesign() {
        layer.borderWidth = 0.3
        layer.borderColor = UIColor(red: 208/255, green: 212/255, blue:217/255, alpha: 1.0).cgColor
        backgroundColor = Colors.whiteBackground
        layer.cornerRadius  = frame.size.height/6
     
        
      
    }
    
}
