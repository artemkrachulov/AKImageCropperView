//
//  AKImageCropperOverlayView.swift
//  AKImageCropper
//  GitHub: https://github.com/artemkrachulov/AKImageCropper
//
//  Created by Krachulov Artem
//  Copyright (c) 2015 Krachulov Artem. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//

import UIKit

class AKImageCropperOverlayView: UIView {

    // MARK: - Properties
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    /// Superview
    var croppperView: AKImageCropperView!
    
    // Corners
    var cornerOffset: CGFloat {
        
        return CGFloat(croppperView.cornerOffset)
    }
    var cornerSize: CGSize {
        
        return croppperView.cornerSize
    }

    // MARK: - Draw
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let cropRect = CGRectOffset(croppperView.cropRect, cornerOffset, cornerOffset)
        
        // Get the Graphics Context
        var context = UIGraphicsGetCurrentContext()
        
        // Draw background
        // Source: Self
        overlayViewDrawBg(rect)
        
        CGContextSaveGState(context)
     
        // Draw crop stroke
        // Source: AKImageCropperViewDelegate
        croppperView.overlayViewDrawStrokeInCropRect(cropRect)
        
        CGContextClearRect(context, cropRect)
        CGContextSaveGState(context)
        
        // Draw grig stroke
        // Source: AKImageCropperViewDelegate
        if croppperView.grid {
            
            croppperView.overlayViewDrawGridInCropRect(cropRect)
            CGContextSaveGState(context)
        }

        // Draw corners
        // Source: AKImageCropperViewDelegate
        
        let topLeftPoint = CGPointMake(CGRectGetMinX(cropRect) - cornerOffset, CGRectGetMinY(cropRect) - cornerOffset)
        croppperView.overlayViewDrawInTopLeftCropRectCornerPoint(topLeftPoint)
        
        let topRightPoint = CGPointMake(CGRectGetMaxX(cropRect) + cornerOffset - cornerSize.width, CGRectGetMinY(cropRect) - cornerOffset)
        croppperView.overlayViewDrawInTopRightCropRectCornerPoint(topRightPoint)
        
        let bottomRightPoint = CGPointMake(CGRectGetMaxX(cropRect) - cornerSize.width + cornerOffset, CGRectGetMaxY(cropRect) - cornerSize.height + cornerOffset)
        croppperView.overlayViewDrawInBottomRightCropRectCornerPoint(bottomRightPoint)
        
        let bottomLeftPoint = CGPointMake(CGRectGetMinX(cropRect) - cornerOffset, CGRectGetMaxY(cropRect)  - cornerSize.height + cornerOffset)
        croppperView.overlayViewDrawInBottomLeftCropRectCornerPoint(bottomLeftPoint)

        CGContextSaveGState(context)
    }
    
    func overlayViewDrawBg(rect: CGRect) {
        
        // Background Color
        croppperView.overlayColor.setFill()
        
        // Draw
        let path = UIBezierPath(rect: CGRectInset(rect, cornerOffset, cornerOffset))
            path.fill()        
    }
}
