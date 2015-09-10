//
//  UIImage.swift
//  Extension file
//
//  Created by Krachulov Artem
//  Copyright (c) 2015 The Krachulovs. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//

import UIKit

extension UIImage {

    /// Crop image from self 
    ///
    /// Usage:
    ///
    ///  var img = image.getImageInRect(CGRectMake(50,50,150,150))
    
    func getImageInRect(rect: CGRect) -> UIImage {
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        // Sets the clipping path to the intersection of the current clipping path with the area defined by the specified rectangle.
        CGContextClipToRect(context, CGRect(origin: CGPointZero, size: rect.size))
        
        drawInRect(CGRect(origin: CGPointMake(-rect.origin.x, -rect.origin.y), size: size))
        
        // Returns an image based on the contents of the current bitmap-based graphics context.
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
}