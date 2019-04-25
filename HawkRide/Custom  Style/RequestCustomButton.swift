//
//  RequestCustomButton.swift
//  Hawk Ride
//
//  Created by Gregory Jones on 4/5/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//

import UIKit

class RequestCustomButton: UIButton {
    
    var originalSize: CGRect?
    
   
    // For storyboard
    
    override func awakeFromNib() {
        setupButton()
    }
    
    /**
     Creating the button's background, button's font,font size, button's dimension, and the label on the button
     * Font: **MontserratSemiBold is a custom font
     * SetTitleColor: indicates the text that is written over the button
     * Author: Myself
     */
    func setupButton() {
         originalSize = self.frame
        layer.borderWidth = 2.0
        layer.borderColor = Colors.redBackground.cgColor
        backgroundColor = Colors.redBackground
        titleLabel?.font    = UIFont(name: Fonts.montserratSemiBold, size: 20)
        layer.cornerRadius  = frame.size.height/2
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize.zero
        setTitleColor(.white, for: .normal)
        
    }
    
  /*  func setupButton() {
    originalSize = self.frame
   // self.layer.cornerRadius = 5.0
    self.layer.shadowRadius = 10.0
    layer.borderColor = Colors.redBackground.cgColor
    backgroundColor = Colors.redBackground
    titleLabel?.font    = UIFont(name: Fonts.montserratSemiBold, size: 20)
    layer.cornerRadius  = frame.size.height/2
    layer.shadowOpacity = 0.5
    layer.shadowOffset = CGSize.zero
    setTitleColor(.white, for: .normal)
        
    } */
    func animateButton(shouldLoad: Bool, withMessage message: String?) {
        
        let spinner = UIActivityIndicatorView()
        
        spinner.style = .gray
        spinner.color = Colors.redBackground
        spinner.alpha = 0.0
        spinner.hidesWhenStopped = true
        spinner.tag = 21
        
        if shouldLoad
        {
            self.addSubview(spinner)
            self.setTitle("", for: .normal)
            
            UIView.animate(withDuration: 0.2, animations:
                {
                    self.layer.cornerRadius = self.frame.height / 2
                    self.frame = CGRect(x: self.frame.midX - (self.frame.height / 2), y: self.frame.origin.y, width: self.frame.height, height: self.frame.height)
                    
            }, completion: { (finished) in
                
                if finished == true {
                    self.addSubview(spinner)
                    spinner.startAnimating()
                    spinner.center = CGPoint(x: self.frame.width / 2 + 1, y: self.frame.width / 2 + 1)
                    spinner.fadeTo(alphaValue: 1.0, withDuration: 0.2)
                }
            })
            self.isUserInteractionEnabled = false
        }
        else
        {
            self.isUserInteractionEnabled = true
            
            for subview in self.subviews
            {
                if subview.tag == 21
                {
                    subview.removeFromSuperview()
                }
            }
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.layer.cornerRadius = 5.0
                self.frame = self.originalSize!
                self.setTitle(message, for: .normal)
            })
        }
    }
}

    
    



