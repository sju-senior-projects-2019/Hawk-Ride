//
//  LocationTableViewCell.swift
//  Hawk Ride
//
//  Created by Gregory Jones on 4/1/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var whiteArrowImage: UIImageView!
    @IBOutlet weak var locationTitle: UILabel!
    @IBOutlet weak var locationDesc: UILabel!
    
    func setLocation(location: Location) {
        locationTitle.text = location.title
        locationDesc.text = location.title
        whiteArrowImage.image = location.image
        
    }
}
