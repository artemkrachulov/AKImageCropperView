//
//  AKImageCropperTouchView.swift
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

//  MARK: - AKImageCropperTouchViewDelegate

@objc protocol AKImageCropperTouchViewDelegate {
  optional func cropRectChanged(rect: CGRect)
  optional func blockScrollViewGestures() -> Bool
}

/// Touch view is first view in AKImageCropperView hierarchy. Used for translating all gestures to scroll view and changing crop frame rectangle when the user touches and moves proper area of view frame.
class AKImageCropperTouchView: UIView {
  
  /// Managing the Delegate
  weak var delegate: AKImageCropperTouchViewDelegate?
  
  //  MARK: - Properties
  
  /// Superview for sending setting properties
  weak var cropperView: AKImageCropperView!
  
  var minimumSize: CGSize { return cropperView.configuration.cropRect.minimumSize }
  var touchArea: CGFloat { return cropperView.configuration.touchArea }
  
  /// Translation receiver (AKImageCropperScollView)
  weak var receiver: UIView!
  
  /// Corner area
  private var cornerTouchArea: CGSize {
    return CGSizeMake(touchArea, touchArea)
  }
  
  var cropRectBeforeMoving: CGRect!
  var cropRectMoved: CGRect!
  
  // Touches points
  var touchBeforeMoving: CGPoint!
  var touchMoved: CGPoint!
  
  // Flags
  var flagScrollViewGesture = true
  
  // Enums
  enum Edge {
    case Top, Left, Right, Bottom
  }
  
  enum RectPart {
    case No
    
    case TopLeftCorner, TopEdge
    case TopRightCorner, RightEdge
    case BottomRightCorner, BottomEdge
    case BottomLeftCorner, LeftEdge
  }
  
  var isCropRect: RectPart = .No
  
  //  MARK:   Draw

  #if AKImageCropperDEBUG
  override func drawRect(rect: CGRect) {
    super.drawRect(rect)

    let context = UIGraphicsGetCurrentContext()
    CGContextSetShouldAntialias(context, true)
    
    CGContextSetFillColorWithColor(context, UIColor.redColor().colorWithAlphaComponent(0.5).CGColor)
    CGContextAddRect(context, topLeftCorner())
    CGContextAddRect(context, topRightCorner())
    CGContextAddRect(context, bottomLeftCorner())
    CGContextAddRect(context, bottomRightCorner())
    CGContextFillPath(context)
    
    CGContextSetFillColorWithColor(context, UIColor.blueColor().colorWithAlphaComponent(0.5).CGColor)
    CGContextAddRect(context, leftEdgeRect())
    CGContextAddRect(context, rightEdgeRect())
    CGContextAddRect(context, topEdgeRect())
    CGContextAddRect(context, bottomEdgeRect())
    CGContextFillPath(context)
  }
  #endif
  
  
  //  MARK:   Crop area parts
  
  func topLeftCorner() -> CGRect {
    return CGRect(origin: CGPointMake(CGRectGetMinX(cropperView.cropRect), CGRectGetMinY(cropperView.cropRect)), size: cornerTouchArea)
  }
  
  func topRightCorner() -> CGRect {
    return CGRect(origin: CGPointMake(CGRectGetMaxX(cropperView.cropRect), CGRectGetMinY(cropperView.cropRect)), size: cornerTouchArea)
  }
  
  func bottomLeftCorner() -> CGRect {
    return CGRect(origin: CGPointMake(CGRectGetMinX(cropperView.cropRect), CGRectGetMaxY(cropperView.cropRect)) , size: cornerTouchArea)
  }
  
  func bottomRightCorner() -> CGRect {
    return CGRect(origin: CGPointMake(CGRectGetMaxX(cropperView.cropRect), CGRectGetMaxY(cropperView.cropRect)), size: cornerTouchArea)
  }
  
  func topEdgeRect() -> CGRect {
    return CGRectMake(CGRectGetMaxX(topLeftCorner()), CGRectGetMinY(topLeftCorner()), CGRectGetWidth(cropperView.cropRect) - touchArea, touchArea)
  }
  
  func bottomEdgeRect() -> CGRect {
    return CGRectMake(CGRectGetMaxX(bottomLeftCorner()),  CGRectGetMaxY(cropperView.cropRect), CGRectGetWidth(cropperView.cropRect) - touchArea, touchArea)
  }
  
  func rightEdgeRect() -> CGRect {
    return CGRectMake(CGRectGetMinX(topRightCorner()), CGRectGetMaxY(topRightCorner()), touchArea, CGRectGetHeight(cropperView.cropRect) - touchArea)
  }
  
  func leftEdgeRect() -> CGRect {
    return CGRectMake(CGRectGetMinX(topLeftCorner()), CGRectGetMaxY(topLeftCorner()), touchArea, CGRectGetHeight(cropperView.cropRect) - touchArea)
  }
  
  func isCropRect (point: CGPoint) -> RectPart {
    if CGRectContainsPoint(topEdgeRect(), point) {
      return .TopEdge
    }
    if CGRectContainsPoint(bottomEdgeRect(), point) {
      return .BottomEdge
    }
    if CGRectContainsPoint(rightEdgeRect(), point) {
      return .RightEdge
    }
    if CGRectContainsPoint(leftEdgeRect(), point) {
      return .LeftEdge
    }
    if CGRectContainsPoint(topLeftCorner(), point) {
      return .TopLeftCorner
    }
    if CGRectContainsPoint(topRightCorner(), point) {
      return .TopRightCorner
    }
    if CGRectContainsPoint(bottomLeftCorner(), point) {
      return .BottomLeftCorner
    }
    if CGRectContainsPoint(bottomRightCorner(), point) {
      return .BottomRightCorner
    }
    return .No
  }
  
  func moveRect(part: RectPart, onTranslation translation: CGPoint) {
    
    cropRectMoved = cropperView.cropRect
    
    switch part {
    case .TopLeftCorner:
      moveEdge(.Top, onDistance: translation.y)
      moveEdge(.Left, onDistance: translation.x)
    case .TopEdge:
      moveEdge(.Top, onDistance: translation.y)
    case .TopRightCorner:
      moveEdge(.Top, onDistance: translation.y)
      moveEdge(.Right, onDistance: translation.x)
    case .RightEdge:
      moveEdge(.Right, onDistance: translation.x)
    case .BottomRightCorner:
      moveEdge(.Bottom, onDistance: translation.y)
      moveEdge(.Right, onDistance: translation.x)
    case .BottomEdge:
      moveEdge(.Bottom, onDistance: translation.y)
    case .BottomLeftCorner:
      moveEdge(.Bottom, onDistance: translation.y)
      moveEdge(.Left, onDistance: translation.x)
    case .LeftEdge:
      moveEdge(.Left, onDistance: translation.x)
    default: ()
    }
    
    // Send new crop rectangle frame to main class
    cropperView.cropRect(cropRectMoved)
  }
  
  func moveEdge(edge: Edge, onDistance distance: CGFloat) {
    
    switch edge {
    case .Top :
      
      // Update sizes.
      
      cropRectMoved.origin.y += distance
      cropRectMoved.size.height -= distance
      
      // Save point if moved touch over touch view. First touched point in top edge
      
      let pointInEdge = touchBeforeMoving.y - CGRectGetMinY(cropRectBeforeMoving)
      
      // Min point if crop rectangle edge will move up
      
      let minStickPoint = pointInEdge
      
      // Max point if crop rectangle edge will move down
      
      let maxStickPoint = CGRectGetMaxY(cropRectBeforeMoving) - minimumSize.height + pointInEdge
      
      // Moving
      
      if touchMoved.y < minStickPoint || CGRectGetMinY(cropRectMoved) < CGRectGetMinY(frame) {
        cropRectMoved.origin.y = 0
        cropRectMoved.size.height = CGRectGetMaxY(cropRectBeforeMoving)
      }
      if  touchMoved.y > maxStickPoint || CGRectGetHeight(cropRectMoved) < minimumSize.height {
        cropRectMoved.origin.y = CGRectGetMaxY(cropRectBeforeMoving) - minimumSize.height
        cropRectMoved.size.height = minimumSize.height
      }
    case .Right :
      
      // Update sizes
      
      cropRectMoved.size.width += distance
      
      // Save point if moved touch over touch view. First touched point in bottom edge

      let pointInEdge = abs(CGRectGetMaxX(cropRectBeforeMoving) - touchBeforeMoving.x)
      
      let maxFrameX = CGRectGetMaxX(frame) - rightEdgeRect().size.width
      
      // Min point if crop rectangle edge will move up

      let minStickPoint = CGRectGetMinX(cropRectBeforeMoving) + pointInEdge + minimumSize.width
      
      // Max point if crop rectangle edge will move down
      
      let maxStickPoint = maxFrameX + pointInEdge
      
      // Moving

      if  touchMoved.x > maxStickPoint || CGRectGetMaxX(cropRectMoved) > maxFrameX {
        cropRectMoved.size.width = maxFrameX - cropRectMoved.origin.x
      }
      if touchMoved.x < minStickPoint || CGRectGetWidth(cropRectMoved) < minimumSize.width {
        cropRectMoved.size.width = minimumSize.width
      }
    case .Bottom :
      
      // Update sizes

      cropRectMoved.size.height += distance
      
      // Save point if moved touch over touch view.First touched point in bottom edge

      let pointInEdge = abs(CGRectGetMaxY(cropRectBeforeMoving) - touchBeforeMoving.y)
      
      let maxFrameY = CGRectGetMaxY(frame) - bottomEdgeRect().size.height
      
      // Min point if crop rectangle edge will move left

      let minStickPoint = CGRectGetMinY(cropRectBeforeMoving) + pointInEdge + minimumSize.height
      
      // Max point if crop rectangle edge will move right

      let maxStickPoint = maxFrameY + pointInEdge
      
      // Moving

      if  touchMoved.y > maxStickPoint || CGRectGetMaxY(cropRectMoved) > maxFrameY {
        cropRectMoved.size.height = maxFrameY - cropRectMoved.origin.y
      }
      if touchMoved.y < minStickPoint || CGRectGetHeight(cropRectMoved) < minimumSize.height {
        cropRectMoved.size.height = minimumSize.height
      }
    case .Left :
      
      // Update sizes

      cropRectMoved.origin.x += distance
      cropRectMoved.size.width -= distance
      
      // Save point if moved touch over touch view. First touched point in top edge

      let pointInEdge = touchBeforeMoving.x - CGRectGetMinX(cropRectBeforeMoving)
      
      // Min point if crop rectangle edge will move left

      let minStickPoint = pointInEdge
      
      // Max point if crop rectangle edge will move right

      let maxStickPoint = CGRectGetMaxX(cropRectBeforeMoving) - minimumSize.width + pointInEdge
      
      // Moving

      if touchMoved.x < minStickPoint || CGRectGetMinX(cropRectMoved) < CGRectGetMinX(frame) {
        cropRectMoved.origin.x = 0
        cropRectMoved.size.width = CGRectGetMaxX(cropRectBeforeMoving)
      }
      if  touchMoved.x > maxStickPoint || CGRectGetWidth(cropRectMoved) < minimumSize.width {
        cropRectMoved.origin.x = CGRectGetMaxX(cropRectBeforeMoving) - minimumSize.width
        cropRectMoved.size.width = minimumSize.width
      }
    }
    
    // Checks for new moved rectangle

    cropRectMoved.origin.y = max(0, cropRectMoved.origin.y)
    cropRectMoved.origin.y = min(cropRectMoved.origin.y, CGRectGetMaxY(cropRectBeforeMoving) - bottomEdgeRect().size.height)
    
    cropRectMoved.size.height = max(minimumSize.height, cropRectMoved.size.height)
    cropRectMoved.size.height = min(CGRectGetHeight(frame) - touchArea, cropRectMoved.size.height)
    
    cropRectMoved.origin.x = max(0, cropRectMoved.origin.x)
    cropRectMoved.origin.x = min(cropRectMoved.origin.x, CGRectGetMaxX(cropRectBeforeMoving) - rightEdgeRect().size.width)
    
    cropRectMoved.size.width = max(minimumSize.width, cropRectMoved.size.width)
    cropRectMoved.size.width = min(CGRectGetWidth(frame) - touchArea, cropRectMoved.size.width)
  }
  
  //  MARK: - Touches
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    if let touch = touches.first {
      
      touchBeforeMoving = touch.locationInView(self)
      
      cropRectBeforeMoving = cropperView.cropRect
      
      isCropRect = isCropRect(touchBeforeMoving)
    }
  }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    if let touch = touches.first {
      
      touchMoved = touch.locationInView(self)
      
      let prevTouchMoved = touch.previousLocationInView(self)
      
      if isCropRect != .No {
        moveRect(isCropRect, onTranslation: CGPointMake(touchMoved.x - prevTouchMoved.x, touchMoved.y - prevTouchMoved.y))
      }
    }
  }
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    
    // Reset
    touchBeforeMoving = nil
    cropRectBeforeMoving = nil
    isCropRect = .No
    
    flagScrollViewGesture = true
  }
  
  //  MARK: - Translation

  override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
    if (pointInside(point, withEvent: event)) {
      
      if isCropRect(point) != .No {
        
        flagScrollViewGesture = false
        
        return self
      }
      return receiver
    }
    return nil
  }
}