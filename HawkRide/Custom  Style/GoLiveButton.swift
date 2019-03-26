//
//  GoLiveButton.swift
//  Hawk Ride
//
//  Created by Gregory Jones on 3/19/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//

import UIKit

class GoLiveButton: UIButton {
    
    /** Convenince initializer must delegate across not up
     * This method init and call super.init to faciliate that
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    // For storyboard
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    /**
     Creating the button's background, button's font,font size, button's dimension, and the label on the button
     * Font: **MontserratSemiBold is a custom font
     * SetTitleColor: indicates the text that is written over the button
     * Author: Myself
     */
    func setupButton() {
        let button = UIButton(type: .custom)
        button.layer.masksToBounds = true
        layer.cornerRadius  = frame.size.width / 3
        backgroundColor = Colors.blueBackground
        
    }
    
}
