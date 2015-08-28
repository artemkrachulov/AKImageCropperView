//
//  AKImageCropperOverlay.swift
//  AKImageCropper
//
//  Created by Krachulov Artem
//  Copyright (c) 2015 Krachulov Artem. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//

import UIKit

@objc protocol AKImageCropperOverlayDelegate {
    
    optional func pinchGesture(overlay: AKImageCropperOverlay, sender: UIPinchGestureRecognizer)
    
    optional func panGesture(overlay: AKImageCropperOverlay, sender: UIPanGestureRecognizer)
}

class AKImageCropperOverlay: UIView {
    
    // MARK: - Settings
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

    var fingerSize: CGFloat = 30.0
    
    var overlayColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    
    var strokeColor = UIColor.whiteColor()
    var cornerColor = UIColor.whiteColor()

    var grid: Bool = true
    var gridColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
    var gridLines: UInt8 = 3

    var delegate: AKImageCropperOverlayDelegate?
    
    // MARK: - Properties
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    private var offset: CGFloat {
        return fingerSize / 2
    }
    private var cornerSize: CGSize {
        return CGSizeMake(fingerSize, fingerSize)
    }
    private var cornerSquareSize: CGSize {
        return CGSizeMake( cornerSize.width + offset - 3,  cornerSize.height + offset - 3)
    }
    private var maxCropSideSize: CGFloat {
        return fingerSize * 2
    }
    private var _frame: CGRect!
    
    private var _cropFrame: CGRect!
    private var cropFrame: CGRect!
    
    private var cropFrameBeforeMoving: CGRect!
    private enum Frame {
        case No
        case Top
        case Left
        case Right
        case Bottom
        case TopLeft
        case TopRight
        case BottomLeft
        case BottomRight
    }
    private enum Edge {
        case Top
        case Left
        case Right
        case Bottom
    }
    private var firstTouchedPoint: CGPoint!
    private var isFrame: Frame = .No
    
    // MARK: - Initialization
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    init() {
        
        super.init(frame: CGRectZero)
        
        // Clear color
        backgroundColor = UIColor.clearColor()
    }
    
    init(frame: CGRect, animated flag: Bool) {
        super.init(frame: frame)
        
        // Clear color
        backgroundColor = UIColor.clearColor()
        
        // Animate
        if flag {
            
            alpha = 0
            
            UIView.animateWithDuration(0.3,
                animations: { () -> Void in
                
                    self.alpha = 1
                }
            )
        }
        
        self.refresh()
        
        // Apply Gestures
        self.applyGesures()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func refresh() {
        
        // Overlay
        if let supView = self.superview {
            
            frame = CGRect(origin: CGPointZero, size: supView.frame.size)
        }
        _frame = CGRectInset(frame, offset, offset)
        
        // Crop Frame
        _cropFrame = fitFrameTo(cropFrame ?? _frame)
    
        
        // Redraw
        self.setNeedsDisplay()
    }
    
    func destroy(animated flag: Bool, completion: (() -> Void)?) {
    
        if flag {
            UIView.animateWithDuration(0.3,
                animations: { () -> Void in
                
                    self.alpha = 0
                
                }
            ) { (done) -> Void in
                
                self.removeFromSuperview()
                
                if completion != nil { completion!() }
            }
        } else {
            
            self.removeFromSuperview()
            
            if completion != nil { completion!() }
        }
        
    }
    
    private func applyGesures() {
        
        var pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: Selector("pinchGesture:"))
        
        var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("panGesture:"))
        panGestureRecognizer.maximumNumberOfTouches = 1
        
        self.addGestureRecognizer(pinchGestureRecognizer)
        self.addGestureRecognizer(panGestureRecognizer)
    }
    
    // MARK: - Crop Frame
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    func setCropFrame(frame: CGRect) {
        
        cropFrame = frame
        
        refresh()
    }
    
    func getCropFrame() -> CGRect {
        
        return CGRectOffset(_cropFrame, -offset, -offset)
    }
    
    // MARK: - Draw view
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    // Corners
    private func topLeftCorner() -> CGRect {
        
        return CGRectMake(CGRectGetMinX(_cropFrame) - 3, CGRectGetMinY(_cropFrame) - 3, cornerSize.width, cornerSize.height);
    }
    private func topRightCorner() -> CGRect {
        
        return CGRectMake(CGRectGetMaxX(_cropFrame) - cornerSize.width + 3, CGRectGetMinY(_cropFrame) - 3, cornerSize.width, cornerSize.height);
    }
    private func bottomLeftCorner() -> CGRect {
        
        return CGRectMake(CGRectGetMinX(_cropFrame) - 3, CGRectGetMaxY(_cropFrame) - cornerSize.height + 3, cornerSize.width, cornerSize.height);
    }
    private func bottomRightCorner() -> CGRect {
        
        return CGRectMake(CGRectGetMaxX(_cropFrame) - cornerSize.width + 3, CGRectGetMaxY(_cropFrame) - cornerSize.height + 3, cornerSize.width, cornerSize.height);
    }

    // Rect
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        // Get the Graphics Context
        var context = UIGraphicsGetCurrentContext()
        CGContextSetShouldAntialias(context, true)
        
        // Fill back
        CGContextSetFillColorWithColor(context, overlayColor.CGColor)
        CGContextAddRect(context, _frame)
        CGContextFillPath(context)
        
        CGContextClearRect(context, _cropFrame)
        CGContextFillPath(context)
        
        // Corners
        CGContextSetFillColorWithColor(context, cornerColor.CGColor)
        
        CGContextSaveGState(context)
        CGContextSetShouldAntialias(context, true)
        
        CGContextAddRect(context, self.topLeftCorner())
        CGContextAddRect(context, self.topRightCorner())
        CGContextAddRect(context, self.bottomLeftCorner())
        CGContextAddRect(context, self.bottomRightCorner())
        
        CGContextFillPath(context)
        
        CGContextClearRect(context, _cropFrame)
        CGContextRestoreGState(context)
        
         #if DEBUG
            
            CGContextSetFillColorWithColor(context, UIColor(red: 255, green: 0, blue: 255, alpha: 0.5).CGColor)
            CGContextAddRect(context, self.isTopLeftCorner())
            CGContextAddRect(context, self.isTopRightCorner())
            CGContextAddRect(context, self.isBottomLeftCorner())
            CGContextAddRect(context, self.isBottomRightCorner())
            CGContextFillPath(context)
            
        #endif

        // Stroke
        CGContextSetStrokeColorWithColor(context, strokeColor.CGColor)
        CGContextSetLineWidth(context, 1)
        CGContextAddRect(context, _cropFrame)
        CGContextStrokePath(context)
        
        // Grid
        CGContextSetStrokeColorWithColor(context, gridColor.CGColor)
        CGContextSetLineWidth(context, 1)
        
        if grid {
            var from, to: CGPoint!
            
            // Vetical lines
            for (var i: UInt8 = 1; i <= gridLines; i++) {
                
                from = CGPointMake(CGRectGetMinX(_cropFrame) + CGRectGetWidth(_cropFrame) / (CGFloat(gridLines) + 1) * CGFloat(i), CGRectGetMinY(_cropFrame))
                to = CGPointMake(from.x, CGRectGetMaxY(_cropFrame))
                
                CGContextMoveToPoint(context, from.x, from.y)
                CGContextAddLineToPoint(context, to.x, to.y)
            }
            
            // Horizontal Lines
            for (var i: UInt8 = 1; i <= gridLines; i++) {
                
                from = CGPointMake(CGRectGetMinX(_cropFrame), CGRectGetMinY(_cropFrame) + CGRectGetHeight(_cropFrame) / (CGFloat(gridLines) + 1) * CGFloat(i))
                to = CGPointMake(CGRectGetMaxX(_cropFrame), from.y)
                
                CGContextMoveToPoint(context, from.x, from.y)
                CGContextAddLineToPoint(context, to.x, to.y)
            }
        }
        
        CGContextStrokePath(context)
        
         #if DEBUG
            
            CGContextSetFillColorWithColor(context, UIColor(red: 0, green: 255, blue: 255, alpha: 0.5).CGColor)
            CGContextAddRect(context, self.isLeftEdgeRect())
            CGContextAddRect(context, self.isRightEdgeRect())
            CGContextAddRect(context, self.isTopEdgeRect())
            CGContextAddRect(context, self.isBottomEdgeRect())
            CGContextFillPath(context)
                
         #endif
    }
    
    
    // MARK: - Move overlay
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    private func isTopLeftCorner() -> CGRect {
        
        return CGRect(origin: CGPointMake(CGRectGetMinX(_cropFrame) - offset, CGRectGetMinY(_cropFrame) - offset), size: cornerSquareSize)
    }
    
    private func isTopRightCorner() -> CGRect {
        
        return CGRect(origin: CGPointMake(CGRectGetMaxX(_cropFrame) - fingerSize + 3, CGRectGetMinY(_cropFrame) - offset), size: cornerSquareSize)
    }
    
    private func isBottomLeftCorner() -> CGRect {
        
        return CGRect(origin: CGPointMake(CGRectGetMinX(_cropFrame) - offset, CGRectGetMaxY(_cropFrame) - fingerSize + 3) , size: cornerSquareSize)
    }
    
    private func isBottomRightCorner() -> CGRect {
        
        return CGRect(origin: CGPointMake(CGRectGetMaxX(_cropFrame) - fingerSize + 3, CGRectGetMaxY(_cropFrame) - fingerSize + 3), size: cornerSquareSize)
    }
    
    private func isEdgeRect() -> CGRect {
        
        return CGRectMake(CGRectGetMinX(self._cropFrame) - offset / 2, CGRectGetMinY(_cropFrame) - offset / 2, CGRectGetWidth(_cropFrame) + offset, CGRectGetHeight(_cropFrame) + offset)
    }
    
    private func isTopEdgeRect() -> CGRect {
        
        return CGRectMake(CGRectGetMaxX(isTopLeftCorner()), CGRectGetMinY(isEdgeRect()) - offset / 2, CGRectGetWidth(isEdgeRect()) - CGRectGetWidth(isTopRightCorner()) * 2 + offset, fingerSize)
    }
    
    private func isBottomEdgeRect() -> CGRect {
        
        return CGRectMake(CGRectGetMaxX(isTopLeftCorner()), CGRectGetMaxY(isEdgeRect()) - offset - offset/2, CGRectGetWidth(isEdgeRect()) - CGRectGetWidth(isTopRightCorner()) * 2 + offset, fingerSize)
    }
    
    private func isRightEdgeRect() -> CGRect {
        
        return CGRectMake(CGRectGetMaxX(isEdgeRect()) - offset - offset/2, CGRectGetMaxY(isTopRightCorner()), fingerSize, CGRectGetHeight(isEdgeRect()) - CGRectGetHeight(isTopRightCorner()) * 2 + offset)
    }
    
    private func isLeftEdgeRect() -> CGRect {
        
        return CGRectMake(CGRectGetMinX(isEdgeRect()) - offset/2, CGRectGetMaxY(isTopLeftCorner()), fingerSize, CGRectGetHeight(isEdgeRect()) - CGRectGetHeight(isTopLeftCorner()) * 2 + offset)
    }
    
    private func isFrame (point: CGPoint) -> Frame {
        
        if CGRectContainsPoint(isTopEdgeRect(), point) {
            
            return .Top
        }
        if CGRectContainsPoint(isBottomEdgeRect(), point) {
            
            return .Bottom
        }
        if CGRectContainsPoint(isRightEdgeRect(), point) {
            
            return .Right
        }
        if CGRectContainsPoint(isLeftEdgeRect(), point) {
            
            return .Left
        }
        if CGRectContainsPoint(isTopLeftCorner(), point) {
            
            return .TopLeft
        }
        if CGRectContainsPoint(isTopRightCorner(), point) {
            
            return .TopRight
        }
        if CGRectContainsPoint(isBottomLeftCorner(), point) {
            
            return .BottomLeft
        }
        if CGRectContainsPoint(isBottomRightCorner(), point) {
            
            return .BottomRight
        }
        
        return .No
    }
    
    private func fitFrameTo(frame: CGRect) -> CGRect {
        
        // Save
        var frame = frame

        // Horizontal

        // Width
        if frame.size.width < maxCropSideSize {
            
            frame.size.width = maxCropSideSize
        }

        // Min
        if frame.origin.x < _frame.origin.x {
            
            frame.origin.x = _frame.origin.x
        }
        
        // Max
        if frame.origin.x > CGRectGetMaxX(_frame) - maxCropSideSize {
            
            frame.origin.x = CGRectGetMaxX(_frame) - maxCropSideSize
            frame.size.width = maxCropSideSize
            
        } else {
            
            if CGRectGetMaxX(frame) > CGRectGetMaxX(_frame) {
                
                frame.size.width = CGRectGetMaxX(_frame) - frame.origin.x
            }
        }
        
        // Vertical

        // Height
        if frame.size.height < maxCropSideSize {
            
            frame.size.height = maxCropSideSize
        }
        
        // Min
        if frame.origin.y < _frame.origin.y {
            
            frame.origin.y = _frame.origin.y
        }

        // Max
        if frame.origin.y > CGRectGetMaxY(_frame) - maxCropSideSize {
            
            frame.origin.y = CGRectGetMaxY(_frame) - maxCropSideSize
            frame.size.height = maxCropSideSize
            
        } else {
            
            if CGRectGetMaxY(frame) > CGRectGetMaxY(_frame) {
                
                frame.size.height = CGRectGetMaxY(_frame) - frame.origin.y
            }
        }
        
        return frame
    }

    private func moveFrame(frame: Frame, onLength length: CGPoint) {
        
        switch frame {
            case .Top :
                
                self.moveEdge(.Top, onLength: length.y)
            
            case .Bottom :
                
                self.moveEdge(.Bottom, onLength: length.y)
                
            case .Right :
                
                self.moveEdge(.Right, onLength: length.x)
                
            case .Left :
                
                self.moveEdge(.Left, onLength: length.x)
                
            case .TopLeft :
                
                self.moveEdge(.Top, onLength: length.y)
                self.moveEdge(.Left, onLength: length.x)
                
            case .TopRight :
                
                self.moveEdge(.Top, onLength: length.y)
                self.moveEdge(.Right, onLength: length.x)
            
            case .BottomLeft :
                
                self.moveEdge(.Bottom, onLength: length.y)
                self.moveEdge(.Left, onLength: length.x)
                
            case .BottomRight :
                
                self.moveEdge(.Bottom, onLength: length.y)
                self.moveEdge(.Right, onLength: length.x)
            
            default: ()
        }
    }
    
    private func moveEdge(edge: Edge, onLength length: CGFloat) {
        
        // Move
        switch edge {
            case .Top :
            
                self._cropFrame.origin.y += length
                self._cropFrame.size.height -= length
            
                if self._cropFrame.size.height < maxCropSideSize {
                    
                    self._cropFrame.origin.y = CGRectGetMaxY(cropFrameBeforeMoving) - maxCropSideSize
                }
            
                if self._cropFrame.origin.y < _frame.origin.y {
                    
                    self._cropFrame.size.height = CGRectGetMaxY(cropFrameBeforeMoving) - _frame.origin.y
            }
            
            case .Bottom :
            
                self._cropFrame.size.height += length
            
                if self._cropFrame.size.height < maxCropSideSize {
                    
                    self._cropFrame.origin.y = CGRectGetMinY(cropFrameBeforeMoving)
                }
            
            
            case .Right :
            
                self._cropFrame.size.width += length
            
                if self._cropFrame.size.width < maxCropSideSize {
                    
                    self._cropFrame.origin.x = CGRectGetMinX(cropFrameBeforeMoving)
                }
                
            
            case .Left :
            
                self._cropFrame.origin.x += length
                self._cropFrame.size.width -= length
            
                if self._cropFrame.size.width < maxCropSideSize {
                    
                    self._cropFrame.origin.x = CGRectGetMaxX(cropFrameBeforeMoving) - maxCropSideSize
                }
                
                if self._cropFrame.origin.x < _frame.origin.x {
                    
                    self._cropFrame.size.width = CGRectGetMaxX(cropFrameBeforeMoving) - _frame.origin.x
                }
            
            default: ()
        }        

        self._cropFrame = fitFrameTo(self._cropFrame)

        self.setNeedsDisplay()
    }
}

// MARK: - AKImageCropperOverlayDelegate
//         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

extension AKImageCropperOverlay {
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        super.touchesBegan(touches as Set<NSObject>, withEvent: event)
        
        if let touch = touches.first as? UITouch {
            
            self.firstTouchedPoint = touch.locationInView(self)
            self.cropFrameBeforeMoving = self._cropFrame
        }
        
    }

    func pinchGesture(sender: UIPinchGestureRecognizer) {
        
        self.delegate?.pinchGesture!(self, sender: sender)
    }
    
    func panGesture(sender: UIPanGestureRecognizer) {
        
        var translation = sender.translationInView(self)
        
        // Began
        if sender.state == .Began {
            
            isFrame = self.isFrame(firstTouchedPoint)
        }
        
        // Progress
        if isFrame != .No {
            
            self.moveFrame(isFrame, onLength: translation)
        } else {
            
            self.delegate?.panGesture!(self, sender: sender)
        }
        
        sender.setTranslation(CGPointZero, inView: self)
        
        // Ended
        if sender.state == .Ended {
            
            isFrame = .No
        }
    }
}