//
//  AKImageCropperUtility.swift
//
//  Created by Artem Krachulov.
//  Copyright (c) 2016 Artem Krachulov. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software
// and associated documentation files (the "Software"), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute,
// sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
// PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
// FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//

import UIKit

class AKImageCropperUtility {
    
    //  MARK: - UIImage Extensions
    
    /// Returns image cropped from selected rectangle.
    class func cropImage(_ image: UIImage?, inRect rect: CGRect) -> UIImage? {
        
        guard let image = image else {
            return nil
        }

        // Create the bitmap context
    
        UIGraphicsBeginImageContext(rect.size)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        // Sets the clipping path to the intersection of the current clipping path with the area defined by the specified rectangle.
    
        context.clip(to: CGRect(origin: CGPoint.zero, size: rect.size))
        
        image.draw(in: CGRect(origin: CGPoint(x: -rect.origin.x, y: -rect.origin.y), size: image.size))
        
        // Returns an image based on the contents of the current bitmap-based graphics context.
    
        let contextImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return contextImage
    }
    
    /// Returns image rotated by specified angle.
    class func rotateImage(_ image: UIImage?, by angle: Double) -> UIImage? {
        
        guard let image = image else {
            return nil
        }
 
        // Calculate the size of the rotated view's containing box for our drawing space
        
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPoint.zero, size: image.size))
        
        rotatedViewBox.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
        let rotatedSize = rotatedViewBox.frame.size
        
        // Create the bitmap context
        
        UIGraphicsBeginImageContext(rotatedSize)
 
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        context.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)
        context.rotate(by: CGFloat(angle))

        image.draw(in: CGRect(origin: CGPoint(x: -image.size.width / 2, y: -image.size.height / 2), size: image.size))
        
        // Returns an image based on the contents of the current bitmap-based graphics context.
        let contextImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return contextImage
    }

    //  MARK: - Scales
    
    /// Returns fit scale value relative to target size with aspect ratio.
    class func getFitScaleMultiplier(_ size1: CGSize, relativeToSize size2: CGSize) -> CGFloat {
        
        guard size1.width != 0 && size1.height != 0 else {
            return 1.0
        }
        
        return min(size2.height / size1.height, size2.width / size1.width)
    }
    
    /// Returns fill scale value relative to target size with aspect ratio.
    class func getFillScaleMultiplier(_ size1: CGSize, relativeToSize size2: CGSize) -> CGFloat {
        return max(size2.height / size1.height, size2.width / size1.width)
    }
    
    /// Centers rectangle (ignoring origin property) and is measured in points.
    class func centers(_ size1: CGSize, relativeToSize size2: CGSize) -> CGPoint {
        return CGPoint(x: size2.width / 2 - size1.width / 2, y: size2.height / 2 - size1.height / 2)
    }
}
