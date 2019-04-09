//
//  UIViewExt.swift
//  Hawk Ride
//
//  Created by Gregory Jones on 4/7/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//

import UIKit

extension UIView {
    
    func fadeTo(alphaValue : CGFloat, withDuration duration : TimeInterval) {
        
        UIView.animate(withDuration: duration) {
            
            self.alpha = alphaValue
        }
    }
    
    
}
