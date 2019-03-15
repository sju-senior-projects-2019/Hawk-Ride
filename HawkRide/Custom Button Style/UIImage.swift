//
//  UIImage.swift
//  HawkRide
//
//  Created by Gregory Jones on 2/5/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//

import UIKit

extension UIImage {
    func alpha(_ value:CGFloat)->UIImage?
    {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

