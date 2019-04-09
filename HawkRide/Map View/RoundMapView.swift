//
//  RoundMapView.swift
//  Hawk Ride
//
//  Created by Gregory Jones on 4/7/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//

import UIKit
import MapKit

class RoundMapView: MKMapView {
    
    override func awakeFromNib() {
        setupView()
    }

    func setupView() {
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 10.0
        
    }
   

}
