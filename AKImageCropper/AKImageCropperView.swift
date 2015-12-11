//
//  AKImageCropperView.swift
//  AKImageCropper
//  GitHub: https://github.com/artemkrachulov/AKImageCropper
//
//  Created by Krachulov Artem
//  Copyright (c) 2015 Krachulov Artem. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//
// Hierarchy
//
//  - - - AKImageCropperView - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// |                                                                                               |
// |   - - - Aspect View - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -   |
// |  |                                                                                         |  |
// |  |   - - - Touch View - - -    - - - Overlay View - - -    - - - Scroll View - - - - - -   |  |
// |  |  |                      |  |                        |  |                             |  |  |
// |  |  |                      |  |                        |  |   - - - Image View - - -    |  |  |
// |  |  |                      |  |                        |  |  |                       |  |  |  |
// |  |  |                      |  |                        |  |  |                       |  |  |  |
// |  |  |                      |  |                        |  |  |                       |  |  |  |
// |  |  |                      |  |                        |  |  |                       |  |  |  |
// |  |  |                      |  |                        |  |  |                       |  |  |  |
// |  |  |                      |  |                        |  |  |                       |  |  |  |
// |  |  |                      |  |                        |  |  |                       |  |  |  |
// |  |  |                      |  |                        |  |  |                       |  |  |  |
// |  |  |                      |  |                        |  |  |                       |  |  |  |
// |  |  |                      |  |                        |  |  | _ _ _ _ _ _ _ _ _ _ _ |  |  |  |
// |  |  | _ _ _ _ _ _ _ _ _ _ _|  | _ _ _ _ _ _ _ _ _ _ _ _|  | _ _ _ _ _ _ _ _ _ _ _ _ _ _ |  |  |
// |  | _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ |  |
// | _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ |


import UIKit

// MARK: - AKImageCropperViewDelegate
//         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

@objc protocol AKImageCropperViewDelegate {
    
    // Any crop rect changes
    optional func cropRectChanged(rect: CGRect)
    
    // Custom overlay view
    optional func overlayViewDrawInTopLeftCropRectCornerPoint(point: CGPoint)
    optional func overlayViewDrawInTopRightCropRectCornerPoint(point: CGPoint)
    optional func overlayViewDrawInBottomRightCropRectCornerPoint(point: CGPoint)
    optional func overlayViewDrawInBottomLeftCropRectCornerPoint(point: CGPoint)
    optional func overlayViewDrawStrokeInCropRect(cropRect: CGRect)
    optional func overlayViewDrawGridInCropRect(cropRect: CGRect)
}

// MARK: - AKImageCropperView
//         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

class AKImageCropperView: UIView {

    // MARK: - Properties
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    var image: UIImage! {
        get {
            
            return flagCreated ? imageView.image : nil
        }
        set(image) {
            
            if image != nil {
                
                // Scroll View
                scrollView.contentSize = image.size
                
                // Image View
                imageView.image = image
                imageView.frame.size = image.size
                
                // Update Sizes
                refresh()
            }
        }
    }

    var cropRect: CGRect  {

        return cropRectSaved ?? CGRect(origin: CGPointZero, size: scrollView.frame.size)
    }
    var cropRectTranslatedToImage: CGRect {
        
        return overlayViewIsActive ?
            CGRectMake((scrollView.contentOffset.x + cropRect.origin.x) / scrollView.zoomScale, (scrollView.contentOffset.y + cropRect.origin.y) / scrollView.zoomScale, cropRect.size.width / scrollView.zoomScale, cropRect.size.height / scrollView.zoomScale) :
            CGRectMake(scrollView.contentOffset.x / scrollView.zoomScale, scrollView.contentOffset.y / scrollView.zoomScale, scrollView.frame.size.width / scrollView.zoomScale, scrollView.frame.size.height / scrollView.zoomScale)
    }
    
    var cropRectMinSize = CGSizeMake(30, 30)
    
    private (set) var overlayViewIsActive = false
    
    // Managing the Delegate
    weak var delegate: AKImageCropperViewDelegate?
    
    // MARK: - Configuration
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    var overlayViewAnimationDuration: NSTimeInterval = 0.3
    var overlayViewAnimationOptions: UIViewAnimationOptions = .CurveEaseOut
    
    var fingerSize = 30 // px
    
    var cornerOffset = 3 // px
    var cornerSize = CGSizeMake(18, 18)
    
    var grid = true
    var gridLines = 2
    
    var overlayColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    var strokeColor = UIColor.whiteColor()
    var cornerColor = UIColor.whiteColor()
    var gridColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
    
    // MARK: - Class Properties
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    private var aspectView: UIView!
    private var touchView: AKImageCropperTouchView!
    private var overlayView: AKImageCropperOverlayView!
    private var overlayViewCornerOffset: CGFloat {
        
        return CGFloat(cornerOffset)
    }
    private (set) var scrollView: AKImageCropperScollView!
    private var scrollViewActiveOffset: CGFloat {
        
        return overlayViewIsActive ? CGFloat(fingerSize) / 2 : 0
    }
    private var scrollViewOffset: CGFloat {
        
        return CGFloat(fingerSize / 2)
    }
    private (set) var imageView: UIImageView!
    
    // Saved crop rect (if rectagle was set in code)
    private var cropRectSaved: CGRect!
    
    // MARK: - Flags
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    /// Blocks any actions if all views not initialized
    private var flagCreated = false
    
    /// Blocks new action until the current not finish
    private var flagOverlayAnimation = false
    
    /// Blocks transition when using built-in transition
    private var flagCropperViewTransitionWithAnimation = true
    
    /// Blocks multiple refreshing if size is same
    private var flagRefresh = true
    
    // MARK: - Initialization
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    init(frame: CGRect, image: UIImage, showOverlayView: Bool) {
        super.init(frame: frame)
        
        create(image, showOverlayView: showOverlayView)
    }
    
    init(image: UIImage, showOverlayView: Bool) {
        super.init(frame:CGRectZero)
        
        create(image, showOverlayView: showOverlayView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        create(nil, showOverlayView: false)
    }
    
    
    private func create(image: UIImage!, showOverlayView: Bool) {
        if !flagCreated {
            
            backgroundColor = UIColor.clearColor()
            
            // Aspect View
            aspectView = UIView()
            aspectView.backgroundColor = UIColor.clearColor()
            aspectView.clipsToBounds = false
            
            addSubview(aspectView)
            
            // Scroll View
            scrollView = AKImageCropperScollView()
            scrollView.backgroundColor = UIColor.clearColor()
            scrollView.delegate = self
            scrollView.clipsToBounds = true
            scrollView.maximumZoomScale = 2
            
            aspectView.addSubview(scrollView)
            
            // Image View
            imageView = UIImageView()
            imageView.backgroundColor = UIColor.clearColor()
            imageView.userInteractionEnabled = true
            scrollView.addSubview(imageView)
            
            // Overlay View
            overlayView = AKImageCropperOverlayView()
            overlayView.backgroundColor = UIColor.clearColor()
            overlayView.hidden = true
            overlayView.alpha = 0
            overlayView.clipsToBounds = false
            overlayView.croppperView = self
            aspectView.addSubview(overlayView)
            
            // Touch View
            touchView = AKImageCropperTouchView()
            touchView.backgroundColor = UIColor.clearColor()
            touchView.delegate = self
            touchView.cropperView = self
            
            touchView.receiver = scrollView
            scrollView.sender = touchView
            aspectView.addSubview(touchView)
            
            // Update flag
            flagCreated = true
            
            self.image = image
            
            if showOverlayView {
                
                showOverlayViewAnimated(false, withCropFrame: nil, completion: nil)
            }
        }
    }
    
    func refresh() {
        
        let views = getViews()
        
        if flagRefresh ? aspectView.frame != views.aspect || scrollView.frame != views.scroll : false {
        
//            #if DEBUG
//            print("AKImageCropperView: refresh()")
//            print("Aspect View Frame: \(aspectView.frame)")
//            print("New Aspect View Frame: \(views.aspect)")
//                
//            print("Scale View Frame: \(scrollView.frame)")
//            print("New Scale View Frame: \(views.scroll)")
//            print("Crop Rect: \(cropRect)")
//            print("Crop Rect Saved: \(cropRectSaved)")
//            print(" ")
//            #endif
        
            // Aspect View
            aspectView.frame = views.aspect
            
            let maxRect = CGRect(origin: CGPointZero, size: scrollView.frame.size)
            let minRect = cropRectMinSize
            
            let newCropRect  = CGRectFit(cropRect, toRect: maxRect, minSize: minRect)
            
            if newCropRect != cropRect && cropRectSaved != nil {
            
                cropRectSaved = newCropRect
                
                delegate?.cropRectChanged!(newCropRect)
            }
            
            // Touch View
            touchView.frame = CGRectInset(views.scroll, -scrollViewOffset, -scrollViewOffset)
            touchView.setNeedsDisplay()
            
            // Overlay View
            overlayView.frame = CGRectInset(views.scroll, -overlayViewCornerOffset, -overlayViewCornerOffset)
            overlayView.setNeedsDisplay()
     
            // Scroll View
            scrollView.frame = views.scroll
            scrollView.minimumZoomScale = views.scale
            scrollView.zoomScale = views.scale
        }
    }
    
    func destroy() {
        
        removeFromSuperview()
    }
    
    // MARK: - Overlay View with Crop Rect
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    func setCropRect(rect: CGRect) {
        
        if overlayViewIsActive {
        
            let maxRect = CGRect(origin: CGPointZero, size: scrollView.frame.size)
            let minRect = cropRectMinSize
            
            cropRectSaved = CGRectFit(rect, toRect: maxRect, minSize: minRect)
            
            touchView.setNeedsDisplay()
            overlayView.setNeedsDisplay()
            
            delegate?.cropRectChanged!(rect)
        }
    }
    
    func showOverlayViewAnimated(flag: Bool, withCropFrame rect: CGRect!, completion: (() -> Void)?) {
        if !flagOverlayAnimation  {
            
            overlayViewIsActive = true
            
            // Set new flags
            flagOverlayAnimation = true
            flagCropperViewTransitionWithAnimation = flag
            
            // Reset crop rectangle
            cropRectSaved = nil
            
            // Set new crop rectangle
            if rect != nil {
                
                setCropRect(rect)
            }
            
            viewWillTransition { () -> Void in
                
                self.overlayView.hidden = false
                
                // Animate
                if flag {
                                        
                    UIView.animateWithDuration(self.overlayViewAnimationDuration,
                        animations: { () -> Void in
                            
                            self.overlayView.alpha = 1
                        }
                    )
                } else {
                    
                    self.overlayView.alpha = 1
                }
                
                // Reset Flags
                self.flagOverlayAnimation = false
                self.flagCropperViewTransitionWithAnimation = true
                
                // Return handler
                if completion != nil {
                    
                    completion!()
                }
            }
        }
    }
    
    func dismissOverlayViewAnimated(flag: Bool, completion: (() -> Void)?) {
        if !flagOverlayAnimation  {

            overlayViewIsActive = false
            
            // Set new flags
            flagOverlayAnimation = true
            flagCropperViewTransitionWithAnimation = flag
            flagRefresh = false
            
            if flag {
                UIView.animateWithDuration(overlayViewAnimationDuration,
                    animations: { () -> Void in
                        
                        self.overlayView.alpha = 0
                    }
                ) { (done) -> Void in
                    
                    self.viewWillTransition(self.dismissOverlayViewAnimatedHandler(completion))
                }
            } else {
                
                viewWillTransition(dismissOverlayViewAnimatedHandler(completion))
            }
        }
    }

    private func dismissOverlayViewAnimatedHandler(completion: (() -> Void)?) -> (() -> Void)? {
    
        // Reset Flags
        flagCropperViewTransitionWithAnimation = true
        flagOverlayAnimation = false
        flagRefresh = true
        
        // Reset crop rectangle
        cropRectSaved = nil
        
        // Return handler
        return completion
    }
    
    func croppedImage() -> UIImage {
        
        let imageRect = cropRectTranslatedToImage
        
        let rect = CGRectMake(CGFloat(Int(imageRect.origin.x)), CGFloat(Int(imageRect.origin.y)), CGFloat(Int(imageRect.size.width)), CGFloat(Int(imageRect.size.height)))

        return image.getImageInRect(rect)
    }

    // MARK: - Helper Methods
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    private func getViews() -> (aspect: CGRect, scroll: CGRect, scale: CGFloat) {
        
        // Update Layouts
        layoutIfNeeded()
        
        if let image = image {
            
            // Crop view with offset
            let viewWithOffset = CGRectInset(frame, scrollViewActiveOffset, scrollViewActiveOffset)
            
            var scale = CGRectFitScale(CGRect(origin: CGPointZero, size: image.size), toRect: viewWithOffset)
                scale = scale < 1 ? scale : 1
        
            let scaledSize = CGSizeMake(image.size.width * scale, image.size.height * scale)
            
            // Scale image with proportion
            let aspectSize = CGSizeMake(scaledSize.width + scrollViewActiveOffset*2, scaledSize.height + scrollViewActiveOffset*2)
            
            let aspect = CGRectCenters(CGRect(origin: CGPointZero, size: aspectSize), inRect: self.frame)
            
            var scroll = CGRect(origin: CGPointZero, size: aspectSize)
                scroll.insetInPlace(dx: scrollViewActiveOffset, dy: scrollViewActiveOffset)
            
            return (CGRectMake(ceil(CGRectGetMinX(aspect),multiplier: 0.5), ceil(CGRectGetMinY(aspect),multiplier: 0.5), ceil(CGRectGetWidth(aspect),multiplier: 0.5), ceil(CGRectGetHeight(aspect),multiplier: 0.5)), CGRectMake(ceil(CGRectGetMinX(scroll),multiplier: 0.5), ceil(CGRectGetMinY(scroll),multiplier: 0.5), ceil(CGRectGetWidth(scroll),multiplier: 0.5), ceil(CGRectGetHeight(scroll),multiplier: 0.5)), scale)
            
        } else {
            
            return (aspect: CGRectZero, scroll: CGRectZero, scale: 0)
        }
    }
    
    // MARK: - Rotate Animation
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    private func viewWillTransition(completion:(() -> Void)?) {
        
        if (CGRectGetWidth(frame) - scrollViewActiveOffset > CGRectGetWidth(aspectView.frame) && CGRectGetHeight(frame) - scrollViewActiveOffset > CGRectGetHeight(aspectView.frame)) || flagCropperViewTransitionWithAnimation == false {

            refresh()

            if completion != nil {
                
                completion!()
            }
            
        } else {
            
//            #if DEBUG
//            print("Animation viewWillTransition")
//            #endif
            
            UIView.animateWithDuration(overlayViewAnimationDuration, delay: 0.0, options: overlayViewAnimationOptions,
                animations: {
                    
                    self.refresh()
                },
                completion: { (finished) -> Void in

                    if completion != nil {
                        
                        completion!()
                    }
                }
            )
        }
    }
}

// MARK: - UIScrollViewDelegate
//         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

extension AKImageCropperView: UIScrollViewDelegate {
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        
        return imageView
    }
}

// MARK: - AKImageCropperViewDelegate
//         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

extension AKImageCropperView: AKImageCropperViewDelegate {
    
    func overlayViewDrawInTopLeftCropRectCornerPoint(point: CGPoint) {

         // Prepare Rects
        let rect = CGRect(origin: point, size: cornerSize)
        let substract = CGRect(origin: CGPointMake(point.x + overlayViewCornerOffset, point.y + overlayViewCornerOffset), size: CGSizeMake(cornerSize.width - overlayViewCornerOffset, cornerSize.height - overlayViewCornerOffset))
        
        // Corner color
        cornerColor.setFill()
        
        // Draw
        let path = UIBezierPath(rect: rect)
            path.appendPath(UIBezierPath(rect: substract).bezierPathByReversingPath())
            path.fill()
    }
    
    func overlayViewDrawInTopRightCropRectCornerPoint(point: CGPoint) {
        
        // Prepare Rects
        let rect = CGRect(origin: point, size: cornerSize)
        let substract = CGRect(origin: CGPointMake(point.x, point.y + overlayViewCornerOffset), size: CGSizeMake(cornerSize.width - overlayViewCornerOffset, cornerSize.height - overlayViewCornerOffset))
        
        // Corner color
        cornerColor.setFill()
        
        // Draw
        let path = UIBezierPath(rect: rect)
            path.appendPath(UIBezierPath(rect: substract).bezierPathByReversingPath())
            path.fill()
    }
    
    func overlayViewDrawInBottomRightCropRectCornerPoint(point: CGPoint) {
        
        // Prepare Rects
        let rect = CGRect(origin: point, size: cornerSize)
        let substract = CGRect(origin: CGPointMake(point.x, point.y), size: CGSizeMake(cornerSize.width - overlayViewCornerOffset, cornerSize.height - overlayViewCornerOffset))
        
        // Corner color
        cornerColor.setFill()
        
        // Draw
        let path = UIBezierPath(rect: rect)
            path.appendPath(UIBezierPath(rect: substract).bezierPathByReversingPath())
            path.fill()
    }
    
    func overlayViewDrawInBottomLeftCropRectCornerPoint(point: CGPoint) {
        
        // Prepare Rects
        let rect = CGRect(origin: point, size: cornerSize)
        let substract = CGRect(origin: CGPointMake(point.x + overlayViewCornerOffset, point.y), size: CGSizeMake(cornerSize.width - overlayViewCornerOffset, cornerSize.height - overlayViewCornerOffset))
        
        // Corner color
        cornerColor.setFill()
        
        // Draw
        let path = UIBezierPath(rect: rect)
            path.appendPath(UIBezierPath(rect: substract).bezierPathByReversingPath())
            path.fill()
    }
    
    func overlayViewDrawStrokeInCropRect(cropRect: CGRect) {
     
        // Stroke color
        strokeColor.set()
        
        // Draw
        let path = UIBezierPath(rect: cropRect)
            path.lineWidth = 1
            path.stroke()
    }
    
    func overlayViewDrawGridInCropRect(cropRect: CGRect) {
        
        // Grid color
        gridColor.set()
        
        // Draw
        let path = UIBezierPath()
            path.lineWidth = 1
        
        // Vetical lines
        for (var i = 1; i <= gridLines; i++) {
            
           let from = CGPointMake(CGRectGetMinX(cropRect) + CGRectGetWidth(cropRect) / (CGFloat(gridLines) + 1) * CGFloat(i), CGRectGetMinY(cropRect))
            
            path.moveToPoint(from)
            path.addLineToPoint(CGPointMake(from.x, CGRectGetMaxY(cropRect)))
        }
        
        // Horizontal Lines
        for (var i = 1; i <= gridLines; i++) {
            
            let from = CGPointMake(CGRectGetMinX(cropRect), CGRectGetMinY(cropRect) + CGRectGetHeight(cropRect) / (CGFloat(gridLines) + 1) * CGFloat(i))
            
            path.moveToPoint(from)
            path.addLineToPoint(CGPointMake(CGRectGetMaxX(cropRect), from.y))
        }
    
        path.stroke()
    }
}

// MARK: - AKImageCropperOverlayDelegate
//         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

extension AKImageCropperView: AKImageCropperTouchViewDelegate {
    
    func cropRectChanged(rect: CGRect) {
        
        self.setCropRect(rect)
    }
}