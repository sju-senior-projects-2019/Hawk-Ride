//
//  SAButtonPart2.swift
//  HawkRide
//
//  Created by Gregory Jones on 2/5/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//

import UIKit

class SAButtonPart2: UIButton {

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
        layer.borderWidth = 1.5
        layer.borderColor = Colors.redBackground.cgColor
        backgroundColor = Colors.whiteBackground
        titleLabel?.font    = UIFont(name: Fonts.montserratSemiBold, size: 14)
        layer.cornerRadius  = frame.size.height/4
        setTitleColor(UIColor(red:161/255, green: 31/255, blue: 53/255, alpha: 1), for: .normal)
       
        
    }
   
   

}
