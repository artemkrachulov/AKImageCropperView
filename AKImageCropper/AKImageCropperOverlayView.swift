//
//  AKImageCropperOverlayView.swift
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

/// Overlay view is second view after touch view in AKImageCropperView hierarchy. 
/// View redraws when crop rectangle will change its frame.
/// Contains visual representation for crop rectangle frame, such as
/// stroke, grid and 4 corners. Al representation can be changed with AKImageCropperViewDelegate protocol.
class AKImageCropperOverlayView: UIView {
  
  //  MARK: - Properties
  
  /// Superview for sending setting properties
  weak var cropperView: AKImageCropperView!
  
  var cornerOffset: CGFloat { return cropperView.configuration.cropRect.cornerOffset }
  var cornerSize: CGSize { return cropperView.configuration.cropRect.cornerSize }
  
  //  MARK: - Draw
  
  override func drawRect(rect: CGRect) {
    super.drawRect(rect)
    
    let cropRect = CGRectOffset(cropperView.cropRect, cornerOffset, cornerOffset)

    let context = UIGraphicsGetCurrentContext()
    
    cropperView.configuration.overlay.bgColor.setFill()

    let path = UIBezierPath(rect: CGRectInset(rect, cornerOffset, cornerOffset))
    path.fill()
    
    CGContextSaveGState(context)
    
    cropperView.cropRectDelegate!.drawStroke(cropRect, configuration: cropperView.configuration)
    
    CGContextClearRect(context, cropRect)
    CGContextSaveGState(context)
    
    //  MARK:   Grid

    if cropperView.configuration.cropRect.grid {
      cropperView.cropRectDelegate!.drawGrid(cropRect, configuration: cropperView.configuration)
      CGContextSaveGState(context)
    }

    //  MARK:   Corners

    let TLPoint = CGPointMake(CGRectGetMinX(cropRect) - cornerOffset, CGRectGetMinY(cropRect) - cornerOffset)
    cropperView.cropRectDelegate!.drawCornerInTopLeftPoint(TLPoint, configuration: cropperView.configuration)
    
    let TRPoint = CGPointMake(CGRectGetMaxX(cropRect) + cornerOffset - cornerSize.width, CGRectGetMinY(cropRect) - cornerOffset)
    cropperView.cropRectDelegate!.drawCornerInTopRightPoint(TRPoint, configuration: cropperView.configuration)
    
    let BRPoint = CGPointMake(CGRectGetMaxX(cropRect) - cornerSize.width + cornerOffset, CGRectGetMaxY(cropRect) - cornerSize.height + cornerOffset)
    cropperView.cropRectDelegate!.drawCornerInBottomRightPoint(BRPoint, configuration: cropperView.configuration)
    
    let BLPoint = CGPointMake(CGRectGetMinX(cropRect) - cornerOffset, CGRectGetMaxY(cropRect)  - cornerSize.height + cornerOffset)
    cropperView.cropRectDelegate!.drawCornerInBottomLeftPoint(BLPoint, configuration: cropperView.configuration)
    
    CGContextSaveGState(context)
  }
}