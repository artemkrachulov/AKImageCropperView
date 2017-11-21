//
//  IC_UIImageExtensions.swift
//  AKImageCropperView
//
//  Created by Artem Krachulov.
//  Copyright (c) 2016 Artem Krachulov. All rights reserved.
//

import Foundation

extension UIImage {
    
    /** Returns image cropped from selected rectangle. */
    
    func ic_imageInRect(_ rect: CGRect) -> UIImage? {
        
        let size = CGSize(width: floor(rect.size.width), height: floor(rect.size.height))
        
        UIGraphicsBeginImageContext(size)
        
        // Create the bitmap context
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        // Sets the clipping path to the intersection of the current clipping path with the area defined by the specified rectangle.
        
        context.clip(to: CGRect(origin: .zero, size: rect.size))
        
        self.draw(in: CGRect(origin: CGPoint(x: -rect.origin.x, y: -rect.origin.y), size: self.size))
        
        // Returns an image based on the contents of the current bitmap-based graphics context.
        
        let contextImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return contextImage
    }
    
    /** Returns image rotated by specified angle. */
    
    func ic_rotateByAngle(_ angle: Double) -> UIImage? {
        
        // Calculate the size of the rotated view's containing box for our drawing space
        
        let rotatedViewBox = UIView(frame: CGRect(origin: .zero, size: self.size))
        rotatedViewBox.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
        
        let rotatedSize = CGSize(width: floor(rotatedViewBox.frame.size.width), height: floor(rotatedViewBox.frame.size.height))
        
        UIGraphicsBeginImageContext(rotatedSize)
        
        // Create the bitmap context
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        context.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)
        context.rotate(by: CGFloat(angle))
        
        self.draw(in: CGRect(origin: CGPoint(x: -self.size.width / 2, y: -self.size.height / 2), size: self.size))
        
        // Returns an image based on the contents of the current bitmap-based graphics context.
        let contextImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return contextImage
    }
}
