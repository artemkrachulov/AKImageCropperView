//
//  AKImageCropperUtility.swift
//  AKImageCropper
//  GitHub: https://github.com/artemkrachulov/AKImageCropper
//
//  Created by Artem Krachulov.
//  Copyright (c) 2016 Artem Krachulov. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//
//  ver. 0.1
//

import UIKit

class AKImageCropperUtility {
  
  //  MARK: - UIImage+Extension.swift
  
  /// Returns image cropped from selected rectangle.
  ///
  /// Original method 
  ///
  ///     func imageInRect(rect: CGRect, currentContext: Bool = false) -> UIImage?
  class func imageInRect(rect: CGRect, fromImage image: UIImage, currentContext: Bool = false) -> UIImage? {
    if currentContext {
      
      // Create the bitmap context
      UIGraphicsBeginImageContext(rect.size)
      
      guard let context = UIGraphicsGetCurrentContext() else {
        return nil
      }
      
      // Sets the clipping path to the intersection of the current clipping path with the area defined by the specified rectangle.
      CGContextClipToRect(context, CGRect(origin: CGPointZero, size: rect.size))
      
      image.drawInRect(CGRect(origin: CGPointMake(-rect.origin.x, -rect.origin.y), size: image.size))
      
      // Returns an image based on the contents of the current bitmap-based graphics context.
      let image = UIGraphicsGetImageFromCurrentImageContext()
      
      UIGraphicsEndImageContext()
      
      return image
      
    } else {
      
      guard let imageRef = CGImageCreateWithImageInRect(image.CGImage, rect) else {
        return nil
      }
      
      // Returns an image based on the imageRef and rotate back to the original orientation
      return UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
    }
  }
  
  //  MARK: - CGRect-CGSize+Extensions.swift
  
  /// Return rectangle where frame increased by multiplier.
  ///
  /// Original method
  ///
  ///     func increase(byMultiplier multiplier: CGFloat) -> CGRect
  class func increaseRect(rect: CGRect, byMultiplier multiplier: CGFloat) -> CGRect {
    return CGRectMake(rect.origin.x*multiplier, rect.origin.y*multiplier, rect.size.width*multiplier, rect.size.height*multiplier)
  }
  
  /// Return size where width and height property increased by multiplier times.
  ///
  /// Original method
  ///
  ///     func increaseBy(multiplier multiplier: CGFloat) -> CGSize
  class func increase(size: CGSize, byMultiplier multiplier: CGFloat) -> CGSize {
    return CGSizeMake(size.width * multiplier, size.height * multiplier)
  }
  
  /// Return size where width and height property increased by value.
  ///
  /// Original method
  ///
  ///     func increase(byDx dx: CGFloat, dy: CGFloat) -> CGSize
  class func increase(size: CGSize, byDx dx: CGFloat, dy: CGFloat) -> CGSize {
    return CGSizeMake(size.width + dx, size.height + dy)
  }

  /// Returns fit scale value relative to target size with aspect ratio.
  ///
  /// Original method
  ///
  ///     CGSizeGetFillScaleMultiplier(size1: CGSize, relativeToSize size2: CGSize) -> CGFloat
  class func getFitScaleMultiplier(size1: CGSize, relativeToSize size2: CGSize) -> CGFloat {
    return min(size2.height / size1.height, size2.width / size1.width)
  }
  
  /// Centers rectangle (ignoring origin property) and is measured in points.
  class func centers(rect1: CGRect, relativeToRect rect2: CGRect) -> CGRect {
    
    var newRect = rect1
    newRect.origin = CGPointMake(rect2.size.width / 2 - rect1.size.width / 2, rect2.size.height / 2 - rect1.size.height / 2)
    
    return newRect
  }
  
  class func rectFit(aRect: CGRect, toRect bRect: CGRect, minSize: CGSize) -> CGRect {
    
    var rect = aRect
    
    rect.size.width = max(minSize.width, aRect.size.width)
    rect.origin.x = max(bRect.origin.x, aRect.origin.x)
    
    if CGRectGetMaxX(rect) > CGRectGetMaxX(bRect) {
      if CGRectGetMaxX(bRect) - minSize.width < rect.origin.x {
        rect.size.width = minSize.width
        rect.origin.x = CGRectGetMaxX(bRect) - rect.size.width
      } else {
        rect.size.width = CGRectGetMaxX(bRect) - rect.origin.x
      }
    }
    
    rect.size.height = max(minSize.height, aRect.size.height)    
    rect.origin.y = max(bRect.origin.y, aRect.origin.y)
    
    if CGRectGetMaxY(rect) > CGRectGetMaxY(bRect) {
      if CGRectGetMaxY(bRect) - minSize.height < rect.origin.y {
        rect.size.height = minSize.height
        rect.origin.y = CGRectGetMaxY(bRect) - rect.size.height
      } else {
        rect.size.height = CGRectGetMaxY(bRect) - rect.origin.y
      }
    }
    
    return rect
  }
  
  //  MARK: - Double-Float+Extensions.swift
  
}