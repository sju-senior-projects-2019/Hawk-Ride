//
//  RequestCustomButton.swift
//  Hawk Ride
//
//  Created by Gregory Jones on 4/5/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//

import UIKit

class RequestCustomButton: UIButton {
    
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
        layer.borderWidth = 2.0
        layer.borderColor = Colors.redBackground.cgColor
        backgroundColor = Colors.redBackground
        titleLabel?.font    = UIFont(name: Fonts.montserratSemiBold, size: 20)
        layer.cornerRadius  = frame.size.height/2
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize.zero
        setTitleColor(.white, for: .normal)
        
    }
    
    
    
}

