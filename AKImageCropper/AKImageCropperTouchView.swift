//
//  AKImageCropperTouchView.swift
//  AKImageCropper
//  GitHub: https://github.com/artemkrachulov/AKImageCropper
//
//  Created by Krachulov Artem
//  Copyright (c) 2015 Krachulov Artem. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//

import UIKit

// MARK: - AKImageCropperTouchViewDelegate
//         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

@objc protocol AKImageCropperTouchViewDelegate {
    
    optional func cropRectChanged(rect: CGRect)
    optional func blockScrollViewGestures() -> Bool
}

// MARK: - AKImageCropperTouchView
//         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

class AKImageCropperTouchView: UIView {
 
    // MARK: - Properties
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

    /// Superview
    var cropperView: AKImageCropperView!
    
    /// Translation receiver (AKImageCropperScollView)
    weak var receiver: UIView!
  
    // Touch dimentions
    var fingerSize: CGFloat {
        
        return CGFloat(cropperView.fingerSize)
    }
    var fingerCornerSize: CGSize {
        
        return CGSizeMake(fingerSize, fingerSize)
    }

    // Crop rectangles
    var cropRect: CGRect {
        
        return cropperView.cropRect
    }
    var cropRectMinSize: CGSize {
    
        return cropperView.cropRectMinSize
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
        case Top
        case Left
        case Right
        case Bottom
    }
 
    enum RectPart {
        case No
        
        case TopLeftCorner
        case TopEdge
        case TopRightCorner
        case RightEdge
        case BottomRightCorner
        case BottomEdge
        case BottomLeftCorner
        case LeftEdge
    }
    
    var isCropRect: RectPart = .No
    
    // Managing the Delegate
    weak var delegate: AKImageCropperTouchViewDelegate?
    
    // MARK: - Draw view
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

//    #if DEBUG
//    override func drawRect(rect: CGRect) {
//        
//        let context = UIGraphicsGetCurrentContext()
//        CGContextSetShouldAntialias(context, true)
//        
//        CGContextSetFillColorWithColor(context, UIColor(red: 255, green: 0, blue: 255, alpha: 0.5).CGColor)
//        CGContextAddRect(context, topLeftCorner())
//        CGContextAddRect(context, topRightCorner())
//        CGContextAddRect(context, bottomLeftCorner())
//        CGContextAddRect(context, bottomRightCorner())
//        CGContextFillPath(context)
//        
//        CGContextSetFillColorWithColor(context, UIColor(red: 0, green: 255, blue: 255, alpha: 0.5).CGColor)
//        CGContextAddRect(context, leftEdgeRect())
//        CGContextAddRect(context, rightEdgeRect())
//        CGContextAddRect(context, topEdgeRect())
//        CGContextAddRect(context, bottomEdgeRect())
//        CGContextFillPath(context)
//    }
//    #endif
    
    // MARK: - Move crop rectangle
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    func topLeftCorner() -> CGRect {
        
        return CGRect(origin: CGPointMake(CGRectGetMinX(cropRect), CGRectGetMinY(cropRect)), size: fingerCornerSize)
    }
    func topRightCorner() -> CGRect {
        
        return CGRect(origin: CGPointMake(CGRectGetMaxX(cropRect), CGRectGetMinY(cropRect)), size: fingerCornerSize)
    }
    func bottomLeftCorner() -> CGRect {
        
        return CGRect(origin: CGPointMake(CGRectGetMinX(cropRect), CGRectGetMaxY(cropRect)) , size: fingerCornerSize)
    }
    func bottomRightCorner() -> CGRect {
        
        return CGRect(origin: CGPointMake(CGRectGetMaxX(cropRect), CGRectGetMaxY(cropRect)), size: fingerCornerSize)
    }
    func topEdgeRect() -> CGRect {
        
        return CGRectMake(CGRectGetMaxX(topLeftCorner()), CGRectGetMinY(topLeftCorner()), CGRectGetWidth(cropRect) - fingerSize, fingerSize)
    }
    func bottomEdgeRect() -> CGRect {
        
        return CGRectMake(CGRectGetMaxX(bottomLeftCorner()),  CGRectGetMaxY(cropRect), CGRectGetWidth(cropRect) - fingerSize, fingerSize)
    }
    func rightEdgeRect() -> CGRect {
        
        return CGRectMake(CGRectGetMinX(topRightCorner()), CGRectGetMaxY(topRightCorner()), fingerSize, CGRectGetHeight(cropRect) - fingerSize)
    }
    func leftEdgeRect() -> CGRect {
        
        return CGRectMake(CGRectGetMinX(topLeftCorner()), CGRectGetMaxY(topLeftCorner()), fingerSize, CGRectGetHeight(cropRect) - fingerSize)
    }
    
    func isCropRect (point: CGPoint) -> RectPart {
        
        if CGRectContainsPoint(topEdgeRect(), point) {
            
            return .TopEdge
            
        } else if CGRectContainsPoint(bottomEdgeRect(), point) {
            
            return .BottomEdge
            
        } else if CGRectContainsPoint(rightEdgeRect(), point) {
            
            return .RightEdge
            
        } else if CGRectContainsPoint(leftEdgeRect(), point) {
            
            return .LeftEdge
            
        } else if CGRectContainsPoint(topLeftCorner(), point) {
            
            return .TopLeftCorner
            
        } else if CGRectContainsPoint(topRightCorner(), point) {
            
            return .TopRightCorner
            
        } else if CGRectContainsPoint(bottomLeftCorner(), point) {
            
            return .BottomLeftCorner
            
        } else if CGRectContainsPoint(bottomRightCorner(), point) {
            
            return .BottomRightCorner
        }
        
        return .No
    }

    func moveRect(part: RectPart, onTranslation translation: CGPoint) {
        
        // copy
        cropRectMoved = cropRect
        
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
        
        cropperView.setCropRect(cropRectMoved)
    }
    
    func moveEdge(edge: Edge, onDistance distance: CGFloat) {
        
        switch edge {
            case .Top :
                
                // Update sizes
                cropRectMoved.origin.y += distance
                cropRectMoved.size.height -= distance
                
                // Save point if moved touch over touch view
                /// First touched point in top edge
                let pointInEdge = touchBeforeMoving.y - CGRectGetMinY(cropRectBeforeMoving)
                
                /// Min point if crop rectangle edge will move up
                let minStickPoint = pointInEdge
                
                /// Max point if crop rectangle edge will move down
                let maxStickPoint = CGRectGetMaxY(cropRectBeforeMoving) - cropRectMinSize.height + pointInEdge
            
                // Process
                if touchMoved.y < minStickPoint || CGRectGetMinY(cropRectMoved) < CGRectGetMinY(frame) {
    
                    cropRectMoved.origin.y = 0
                    cropRectMoved.size.height = CGRectGetMaxY(cropRectBeforeMoving)
                }
                if  touchMoved.y > maxStickPoint || CGRectGetHeight(cropRectMoved) < cropRectMinSize.height {
                    
                    cropRectMoved.origin.y = CGRectGetMaxY(cropRectBeforeMoving) - cropRectMinSize.height
                    cropRectMoved.size.height = cropRectMinSize.height
                }
            
            case .Right :
                
                // Update size
                cropRectMoved.size.width += distance
                
                // Save point if moved touch over touch view
                /// First touched point in bottom edge
                let pointInEdge = abs(CGRectGetMaxX(cropRectBeforeMoving) - touchBeforeMoving.x)
                
                let maxFrameX = CGRectGetMaxX(frame) - rightEdgeRect().size.width
                
                /// Min point if crop rectangle edge will move up
                let minStickPoint = CGRectGetMinX(cropRectBeforeMoving) + pointInEdge + cropRectMinSize.width
                
                /// Max point if crop rectangle edge will move down
                let maxStickPoint = maxFrameX + pointInEdge
                
                if  touchMoved.x > maxStickPoint || CGRectGetMaxX(cropRectMoved) > maxFrameX {
                    
                    cropRectMoved.size.width = maxFrameX - cropRectMoved.origin.x
                }
                if touchMoved.x < minStickPoint || CGRectGetWidth(cropRectMoved) < cropRectMinSize.width {
                    
                    cropRectMoved.size.width = cropRectMinSize.width
                }
            
            case .Bottom :
                
                // Update size
                cropRectMoved.size.height += distance
            
                // Save point if moved touch over touch view
                /// First touched point in bottom edge
                let pointInEdge = abs(CGRectGetMaxY(cropRectBeforeMoving) - touchBeforeMoving.y)
     
                let maxFrameY = CGRectGetMaxY(frame) - bottomEdgeRect().size.height
                
                /// Min point if crop rectangle edge will move left
                let minStickPoint = CGRectGetMinY(cropRectBeforeMoving) + pointInEdge + cropRectMinSize.height
                
                /// Max point if crop rectangle edge will move right
                let maxStickPoint = maxFrameY + pointInEdge
                
                if  touchMoved.y > maxStickPoint || CGRectGetMaxY(cropRectMoved) > maxFrameY {
                        
                    cropRectMoved.size.height = maxFrameY - cropRectMoved.origin.y
                }
                if touchMoved.y < minStickPoint || CGRectGetHeight(cropRectMoved) < cropRectMinSize.height {
                    
                    cropRectMoved.size.height = cropRectMinSize.height
                }
            case .Left :
                
                // Update sizes
                cropRectMoved.origin.x += distance
                cropRectMoved.size.width -= distance
            
                // Save point if moved touch over touch view
                /// First touched point in top edge
                let pointInEdge = touchBeforeMoving.x - CGRectGetMinX(cropRectBeforeMoving)
                
                /// Min point if crop rectangle edge will move left
                let minStickPoint = pointInEdge
                
                /// Max point if crop rectangle edge will move right
                let maxStickPoint = CGRectGetMaxX(cropRectBeforeMoving) - cropRectMinSize.width + pointInEdge
                
                // Process
                if touchMoved.x < minStickPoint || CGRectGetMinX(cropRectMoved) < CGRectGetMinX(frame) {
                    
                    cropRectMoved.origin.x = 0
                    cropRectMoved.size.width = CGRectGetMaxX(cropRectBeforeMoving)
                }
                if  touchMoved.x > maxStickPoint || CGRectGetWidth(cropRectMoved) < cropRectMinSize.width {
                    
                    cropRectMoved.origin.x = CGRectGetMaxX(cropRectBeforeMoving) - cropRectMinSize.width
                    cropRectMoved.size.width = cropRectMinSize.width
                }
        }
       
        // Another test crop rectangle sizes
        cropRectMoved.origin.y = max(0, cropRectMoved.origin.y)
        cropRectMoved.origin.y = min(cropRectMoved.origin.y, CGRectGetMaxY(cropRectBeforeMoving) - bottomEdgeRect().size.height)
        
        cropRectMoved.size.height = max(cropRectMinSize.height, cropRectMoved.size.height)
        cropRectMoved.size.height = min(CGRectGetHeight(frame) - fingerSize, cropRectMoved.size.height)
        
        cropRectMoved.origin.x = max(0, cropRectMoved.origin.x)
        cropRectMoved.origin.x = min(cropRectMoved.origin.x, CGRectGetMaxX(cropRectBeforeMoving) - rightEdgeRect().size.width)
        
        cropRectMoved.size.width = max(cropRectMinSize.width, cropRectMoved.size.width)
        cropRectMoved.size.width = min(CGRectGetWidth(frame) - fingerSize, cropRectMoved.size.width)
    }
}

// MARK: - Translation
//         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

extension AKImageCropperTouchView {
    
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


// MARK: - Touches
//         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

extension AKImageCropperTouchView {
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if let touch = touches.first {
            
            touchBeforeMoving = touch.locationInView(self)
            
            cropRectBeforeMoving = cropRect
            
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
}