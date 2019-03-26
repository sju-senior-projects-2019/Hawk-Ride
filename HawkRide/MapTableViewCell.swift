//
//  MapTableViewCell.swift
//  Hawk Ride
//
//  Created by Gregory Jones on 3/26/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//

import UIKit

class MapTableViewCell: UITableViewCell {

   
    @IBOutlet weak var locationButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
