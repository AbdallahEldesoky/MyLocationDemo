//
//  UIImage+resize.swift
//  MyLocationsDemo
//
//  Created by Abdallah on 9/13/19.
//  Copyright © 2019 Abdallah Eldesoky. All rights reserved.
//

import UIKit


extension UIImage {
    
    func resized(withBounds bounds: CGSize) -> UIImage {
        
        let horizontalRatio = bounds.width / size.width
        let verticalRatio = bounds.height / size.height
        let ratio = min(horizontalRatio, verticalRatio)
        
        let newImageSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newImageSize, true, 0)
        draw(in: CGRect(origin: .zero, size: newImageSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? UIImage()
    }
}
