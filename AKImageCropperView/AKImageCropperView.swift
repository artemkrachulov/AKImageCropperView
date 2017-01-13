//
//  AKImageCropperView.swift
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

typealias CGPointPercentage = CGPoint

open class AKImageCropperView: UIView, UIScrollViewDelegate, UIGestureRecognizerDelegate, AKImageCropperCropViewDelegate {
    
    // MARK: Initialization OBJECTS(VIEWS) & theirs parameters
    
    // MARK: ** Rotate view **
    
    fileprivate (set) lazy var rotateView: UIView! = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()
    
    // MARK: ** Scroll view **
    /*
    open lazy var scrollView: UIScrollView! = {
        let view = UIScrollView()
        view.delegate = self
        view.alwaysBounceVertical = true
        view.alwaysBounceHorizontal = true
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()*/
    
    var scrollView: AKImageCropperScrollView!
    
    


    private var scrollViewFrame: CGRect {
        return CGRect(
            origin  : .zero,
            size    : ((angle / M_PI_2).truncatingRemainder(dividingBy: 2)) == 1
                ? CGSize(width: frame.size.height, height: frame.size.width)
                : frame.size)
    }
    
    /// Scroll view minimum edge insets depending on
    
    private var scrollViewMinEdgeInsets: UIEdgeInsets {
        guard let cropView = cropView else {
            return .zero
        }
        return cropView.alpha == 0 ? .zero : cropView.configuraiton.cropRectInsets
    }

    /// Max crop view frame reversed by angle with currect instest.
    
    open var cropRectMaxFrame: CGRect {
        
        var reversedInsets: UIEdgeInsets
        
        switch angle {
        case M_PI_2:
            reversedInsets = UIEdgeInsetsMake(scrollViewMinEdgeInsets.right, scrollViewMinEdgeInsets.top, scrollViewMinEdgeInsets.left, scrollViewMinEdgeInsets.bottom)
        case M_PI:
            reversedInsets = UIEdgeInsetsMake(scrollViewMinEdgeInsets.bottom, scrollViewMinEdgeInsets.right, scrollViewMinEdgeInsets.top, scrollViewMinEdgeInsets.left)
        case M_PI_2 * 3:
            reversedInsets = UIEdgeInsetsMake(scrollViewMinEdgeInsets.left, scrollViewMinEdgeInsets.bottom, scrollViewMinEdgeInsets.right, scrollViewMinEdgeInsets.top)
        default:
            reversedInsets = scrollViewMinEdgeInsets
        }
        
        return CGRect(
            x       : reversedInsets.left,
            y       : reversedInsets.top,
            width   : scrollViewFrame.size.width - (reversedInsets.left + reversedInsets.right),
            height  : scrollViewFrame.size.height - (reversedInsets.top + reversedInsets.bottom))
    }
    
    // MARK: ** Overlay crop view **
    
    open var cropView: AKImageCropperCropView? {
        didSet {
            
            cropView?.cropperView = self
            cropView?.delegate = self
            
            if cropView != nil && rotateView != nil {
                rotateView.addSubview(cropView!)
            }
        }
    }
  
    /// Determines the overlay view current state. Default is false.
    open var isOverlayCropViewActive: Bool = false
    
    ///
    fileprivate var isAnimation: Bool = false

    /**
     
     Show the overlay view with crop rectangle.
     
     - parameter duration: The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them. Default value is 0.
     - parameter options: A mask of options indicating how you want to perform the animations. For a list of valid constants, see UIViewAnimationOptions. Default value is .curveEaseInOut.
     - parameter completion: A block object to be executed when the animation sequence ends. This block has no return value and takes a single Boolean argument that indicates whether or not the animations actually finished before the completion handler was called. If the duration of the animation is 0, this block is performed at the beginning of the next run loop cycle. This parameter may be NULL.
     
     */
    
    open func showOverlayCropView(animationDuration duration: TimeInterval = 0, options: UIViewAnimationOptions = .curveEaseInOut, completion: ((Bool) -> Void)? = nil) {
        
        
        guard cropView != nil && !isOverlayCropViewActive && !isAnimation else {
            return
        }
        
        updateScrollViewSavedVariables()
        
        cancelZoomingToFitTimer()

        if duration == 0 {
            
            /* Before actions */
            
            isAnimation = true
            
            cropView?.alpha = 1
            
            layoutSubviews()

            /* After actions */
            
            isAnimation = false
            
            /* Completion */
            
            isOverlayCropViewActive = true
            
            completion?(true)
            
        } else {
            
            /* Before actions */
            
            isAnimation = true
            
            let savedContentOffsetPercentage = self.savedContentOffsetPercentage(from: scrollView.contentOffset)

            UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                
                self.layoutSubviews()

                /**
                 
                 Update scroll view content offsets 
                 using active zooming scale and insets.
                 
                 */

                self.scrollView.contentOffset = self.contentOffset(from: savedContentOffsetPercentage)
                
            }, completion: { _ in

                UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                    
                    self.cropView?.alpha = 1

                }, completion: { isFinished in
                    
                    /* After actions */
                    
                    self.isAnimation = false
                    
                    /* Completion */
                    
                    self.isOverlayCropViewActive = true
                    
                    completion?(isFinished)
                })
            })
        }
    }
    
    /**
     
     Hide the overlay view with crop rectangle.
     
     - parameter duration: The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them. Default value is 0.
     - parameter options: A mask of options indicating how you want to perform the animations. For a list of valid constants, see UIViewAnimationOptions. Default value is .curveEaseInOut.
     - parameter completion: A block object to be executed when the animation sequence ends. This block has no return value and takes a single Boolean argument that indicates whether or not the animations actually finished before the completion handler was called. If the duration of the animation is 0, this block is performed at the beginning of the next run loop cycle. This parameter may be NULL.
     
     */
    
    open func hideOverlayCropView(animationDuration duration: TimeInterval = 0, options: UIViewAnimationOptions = .curveEaseInOut, completion: ((Bool) -> Void)? = nil) {
        
        guard cropView != nil && isOverlayCropViewActive && !isAnimation else {
            return
        }

        updateScrollViewSavedVariables()
            
        cancelZoomingToFitTimer()
        
        if duration == 0 {
            
            /* Before actions */
            
            isAnimation = true
            
            cropView?.alpha = 0
            
            layoutSubviews()
            
            /* After actions */
            
            isAnimation = false
            
            /* Completion */
            
            isOverlayCropViewActive = false
            
            completion?(true)
            
        } else {
            
            /* Before actions */
            
            isAnimation = true
            
            
            let savedContentOffsetPercentage = self.savedContentOffsetPercentage(from: CGPoint(
                x: scrollView.contentOffset.x + scrollView.contentInset.left,
                y: scrollView.contentOffset.y + scrollView.contentInset.top))
            
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                
                self.cropView?.alpha = 0
                
            }, completion: { _ in

                UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                    
                    self.layoutSubviews()
                    
                    /**
                     
                     Update scroll view content offsets
                     using active zooming scale and insets.
                     
                     */
                    
                    self.scrollView.contentOffset = self.contentOffset(from: savedContentOffsetPercentage)
                    
                }, completion: { isFinished in
                    
                    /* After actions */
                    
                    self.isAnimation = false
                    
                    /* Completion */
                    
                    self.isOverlayCropViewActive = false
                    
                    completion?(isFinished)
                })
            })
        }
    }
    
    // MARK: ** Image view **

    fileprivate (set) lazy var imageView: UIImageView! = {
        let view = UIImageView()
        return view
    }()
    
    // MARK: Initializing an Image Cropper View
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    /**
     
     Returns an image cropper view initialized with the specified image.
     
     - parameter image: The initial image to display in the image cropper view.     
     
     */
    
    public init(image: UIImage?) {
        super.init(frame:CGRect.zero)
        
        initialize()
        
        self.image = image
    }
    
    fileprivate func initialize() {
        
        /**
         
         Create views layout
         Step by step
         
         1. Scroll view ‹‹ Image view
         
         */

        scrollView.addSubview(imageView)
        rotateView.addSubview(scrollView)

        /* Crop view with crop rectangle */
        
        cropView = AKImageCropperCropView()
        
        /* Main rotate view container */
        
        addSubview(rotateView)
        
        /* Observers */
        
        for forKeyPath in ["frame", "contentSize", "contentOffset", "contentInset"] {
            scrollView.addObserver(self, forKeyPath: forKeyPath, options: [.new], context: nil)
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        guard let keyPath = keyPath  else {
            return
        }
        
        switch keyPath {
        case "frame":
            if let _ = change![NSKeyValueChangeKey.newKey] {
                cropView?.matchForegroundToScrollView(scrollView: scrollView)
            }
            
        case "contentInset":
            if let _ = change![NSKeyValueChangeKey.newKey] {
                cropView?.matchForegroundToScrollView(scrollView: scrollView)
                cropView?.layoutSubviews()
            }
        case "contentOffset":
            if let _ = change![NSKeyValueChangeKey.newKey] {
                cropView?.matchForegroundToScrollView(scrollView: scrollView)
            }
        case "contentSize":
            if let _ = change![NSKeyValueChangeKey.newKey] {}
        default: ()
        }
    }
    

    // MARK: Accessing the Displayed Images

    /// The image displayed in the image cropper view. Default is nil.
    open var image: UIImage? {
        didSet {

            guard let image = image else {
                return
            }
            
            //  Prepare scroll view to changing image
            
            scrollView.maximumZoomScale = 1
            scrollView.minimumZoomScale = 1
            scrollView.zoomScale = 1
            
            //  Reset Image View
            
            imageView.image = image
            imageView.frame.size = image.size
            
            cropView?.image = image
           
            
            angle = 0
            rotateView.transform = CGAffineTransform.identity
            
            resetScrollViewSavedVariables()
            cancelZoomingToFitTimer()
            
            scrollView.contentSize = image.size
            
            layoutSubviews()
        }
    }
    
    var cropRect: CGRect {
        
        let f =  CGRect(x: scrollView.contentInset.left,
                        y: scrollView.contentInset.top,
                        width: scrollView.frame.size.width  - scrollView.contentInset.left - scrollView.contentInset.right,
                        height: scrollView.frame.size.height - scrollView.contentInset.top - scrollView.contentInset.bottom)
        
        return f
        
        /*
        let size = self.size(
            size    : scrollView.contentSize,
            minSize : CGSize.zero,
            maxSize : reversedInsetFrame.size)
        
        
        let origin = center(size: size)
        
        */
        
//        return CGRect(origin: origin, size: size)
    }
    
    /// Cropperd image in the specified crop rectangle.
    open var croppedImage: UIImage? {
        
        let cropRectScaled = CGRect(
            x       : scrollView.contentOffset.x / scrollView.zoomScale,
            y       : scrollView.contentOffset.y / scrollView.zoomScale,
            width   : scrollView.frame.size.width / scrollView.zoomScale,
            height  : scrollView.frame.size.height / scrollView.zoomScale)
        
        return AKImageCropperUtility.rotateImage(AKImageCropperUtility.cropImage(image, inRect: cropRectScaled), by: angle)
    }
   
    /// Returns the image edited state flag.
    open var isEdited: Bool {
        
        guard let image = image else {
            return false
        }
        
        let fitScaleMultiplier = AKImageCropperUtility.getFitScaleMultiplier(image.size, relativeToSize: cropRectMaxFrame.size)
        
        return angle != 0 || fitScaleMultiplier != scrollView.minimumZoomScale || fitScaleMultiplier != scrollView.zoomScale
    }
    
    // MARK: Managing the Delegate
    
    weak open var delegate: AKImageCropperViewDelegate?
    
    // MARK: - Life cycle
    
    override open func layoutSubviews() {
        super.layoutSubviews()

        rotateView.frame = CGRect(origin: .zero, size: self.frame.size)
        
        if cropView?.alpha == 1 {
            
            /* Zoom */
            
            let fitScaleMultiplier = AKImageCropperUtility.getFitScaleMultiplier(cropRect.size, relativeToSize: cropRectMaxFrame.size)

            scrollView.maximumZoomScale     *= fitScaleMultiplier
            scrollView.minimumZoomScale     *= fitScaleMultiplier
            scrollView.zoomScale            *= fitScaleMultiplier
            
            /* Content inset */
            
            let size = CGSize(
                width   : cropRect.size.width * fitScaleMultiplier,
                height  : cropRect.size.height * fitScaleMultiplier)
            
            scrollView.contentInset = centeredInsets(from: size, to: cropRectMaxFrame.size)
            
            /* Content offset */
            
            let savedFitScaleMultiplier = AKImageCropperUtility.getFitScaleMultiplier(scrollViewSaved.cropRectSize, relativeToSize: cropRectMaxFrame.size)

            
            var contentOffset = CGPoint(
                x: scrollViewSaved.contentOffset.x * savedFitScaleMultiplier,
                y: scrollViewSaved.contentOffset.y * savedFitScaleMultiplier)
            
            contentOffset.x -= scrollView.contentInset.left
            contentOffset.y -= scrollView.contentInset.top
            
            scrollView.contentOffset = contentOffset
        
        } else {
            
            let fitScaleMultiplier = image == nil
                ? 1
                : AKImageCropperUtility.getFitScaleMultiplier(image!.size, relativeToSize: cropRectMaxFrame.size)
            
            scrollView.maximumZoomScale = fitScaleMultiplier * 1000
            scrollView.minimumZoomScale = fitScaleMultiplier
            scrollView.zoomScale        = fitScaleMultiplier * scrollViewSaved.scaleAspectRatio
        }

        scrollView?.frame = scrollViewFrame
        
        cropView?.frame = scrollViewFrame
        cropView?.layoutSubviews()   
    }
    

    

    
    deinit {
        #if AKImageCropperViewDEBUG
            print("deinit AKImageCropperView")
        #endif
    }
    
    // MARK: - Rotate
    
    /// Current rotation angle
    fileprivate var angle: Double = 0
    
    /**
     
     Rotate the image on the angle in multiples of 90 degrees (M_PI_2).
     
     - parameter angle: Rotation angle. The angle a multiple of 90 degrees (M_PI_2).
     - parameter duration: The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them. Default value is 0.
     - parameter options: A mask of options indicating how you want to perform the animations. For a list of valid constants, see UIViewAnimationOptions. Default value is .curveEaseInOut.
     - parameter completion: A block object to be executed when the animation sequence ends. This block has no return value and takes a single Boolean argument that indicates whether or not the animations actually finished before the completion handler was called. If the duration of the animation is 0, this block is performed at the beginning of the next run loop cycle. This parameter may be NULL.
     
     */
    open func rotateImage(_ angle: Double, withDuration duration: TimeInterval = 0, options: UIViewAnimationOptions = .curveEaseInOut, completion: ((Bool) -> Void)? = nil) {
        
        guard angle.truncatingRemainder(dividingBy: M_PI_2) == 0 else {
            return
        }
        
        self.angle = angle
        
        updateScrollViewSavedVariables()
        
        let animations: () -> Void = { _ in
            
            self.rotateView.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
            self.layoutSubviews()
        }
        
        if duration == 0 {
            animations()
            completion?(true)
        } else {
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations, completion: { isFinished in
                
                self.updateScrollViewSavedVariables()
                
                completion?(isFinished)
            })
        }
    }
    
    /// Return AKImageCropperView to initial state.
    open func resetImage(animationDuration duration: TimeInterval = 0, options: UIViewAnimationOptions = .curveEaseInOut, completion: ((Bool) -> Void)? = nil) {
    
        angle = 0
        resetScrollViewSavedVariables()
        
        let animations: () -> Void = { _ in
            
            self.rotateView.transform = CGAffineTransform.identity
            self.layoutSubviews()
        }
        
        if duration == 0 {
            animations()
            completion?(true)
        } else {
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations, completion: { isFinished in
                completion?(isFinished)
            })
        }
    }
    
    // MARK: - Touch
    /*
    @objc fileprivate func pressGestureAction(_ gesture: UITapGestureRecognizer) {
        
        if gesture.state == .began {
            beganGestureActions()
        } else if gesture.state == .ended || gesture.state == .cancelled {
            endedGestureActions()
        }
    }
    */
    
    fileprivate func cropViewBeforeActions() {
        
        cropView?.gridVisibility(visible: true)
        cropView?.blurVisibility(visible: false)
        
        cancelZoomingToFitTimer()
    }
    
    fileprivate func cropViewAfterActions() {
        startZoomingToFitTimer()
    }
    
    // MARK: - Zooming to tit
    
    fileprivate var zoomingToFitTimer: Timer?
    
    fileprivate func startZoomingToFitTimer() {
        
        cancelZoomingToFitTimer()
        
        guard let zoomingToFitDelay = cropView?.configuraiton.zoomingToFitDelay else {
            return
        }
        
        zoomingToFitTimer = Timer.scheduledTimer(timeInterval: zoomingToFitDelay, target: self, selector: #selector(zoomToFitAction), userInfo: nil, repeats: false)
    }
    
    fileprivate func cancelZoomingToFitTimer() {
        
        zoomingToFitTimer?.invalidate()
        zoomingToFitTimer = nil
    }
    
    @objc fileprivate func zoomToFitAction() {
        
        updateScrollViewSavedVariables()        

        cropView?.gridVisibility(visible: false)
        cropView?.blurVisibility(visible: true)
        
        UIView.animate(withDuration: self.cropView!.configuraiton.animation.duration, delay: 0, options: self.cropView!.configuraiton.animation.options, animations: {
            
            self.layoutSubviews()
            
        }, completion: { isDone in
            
//            self.delegate?.imageCropperViewDidChangeCropRect(view: self, cropRect: self.cropView!.cropRect)
        })
    }
    
    // MARK: - Helper methods
    
    private func updateScrollViewSavedVariables() {
        scrollViewSaved.scaleAspectRatio    = scrollView.zoomScale / scrollView.minimumZoomScale
        scrollViewSaved.contentOffset       = CGPoint(
            x: scrollView.contentOffset.x + scrollView.contentInset.left,
            y: scrollView.contentOffset.y + scrollView.contentInset.top)
        scrollViewSaved.cropRectSize        = cropRect.size
    }
    
    private func resetScrollViewSavedVariables() {
        scrollViewSaved = ScrollViewSaved(
            scaleAspectRatio    : 1.0,
            contentOffset       : CGPoint.zero,
            cropRectSize        : CGSize.zero)
    }
    
    private func centeredInsets(from size: CGSize, to relativeSize: CGSize) -> UIEdgeInsets {
        
        let center = AKImageCropperUtility.centers(size, relativeToSize: relativeSize)
        
        /* Fix insets direct to orientation */
        
        return UIEdgeInsetsMake(
            center.y + scrollViewMinEdgeInsets.top,
            center.x + scrollViewMinEdgeInsets.left,
            center.y + scrollViewMinEdgeInsets.bottom,
            center.x + scrollViewMinEdgeInsets.right)
    }
    
    private func size(size: CGSize, minSize: CGSize, maxSize: CGSize) -> CGSize {
        
        var size = size
        
        if size.width > maxSize.width {
            size.width = maxSize.width
        }
        
        if size.height > maxSize.height {
            size.height = maxSize.height
        }
        
        if size.width < minSize.width {
            size.width = minSize.width
        }
        
        if size.height < minSize.height {
            size.height = minSize.height
        }
        
        return size
    }
    
    
    private func savedContentOffsetPercentage(from contentOffset: CGPoint) -> CGPointPercentage {
        
        var contentOffsetPercentage = CGPointPercentage(x: 0, y: 0)
        let contentSize = CGSize(
            width   : scrollView.contentSize.width - cropRect.width,
            height  : scrollView.contentSize.height - cropRect.height)
        
        if contentOffset.x > 0 && contentSize.width != 0 {
            contentOffsetPercentage.x = contentOffset.x / contentSize.width
        }
        
        if contentOffset.y > 0 && contentSize.height != 0  {
            contentOffsetPercentage.y = contentOffset.y / contentSize.height
        }
        
        return contentOffsetPercentage
    }
    
    private func contentOffset(from savedContentOffsetPercentage: CGPointPercentage) -> CGPoint {
        
        var contentOffset = CGPoint(
            x: scrollView.contentInset.left > scrollViewMinEdgeInsets.left
                ? 0
                : ((scrollView.contentSize.width - cropRectMaxFrame.size.width) * savedContentOffsetPercentage.x),
            y: scrollView.contentInset.top > scrollViewMinEdgeInsets.left
                ? 0
                : ((scrollView.contentSize.height - cropRectMaxFrame.size.height) * savedContentOffsetPercentage.y))
        
        contentOffset.x -= scrollView.contentInset.left
        contentOffset.y -= scrollView.contentInset.top
    
        return contentOffset
    }
    
    
    
    // MARK: - UIScrollViewDelegate
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        cropViewAfterActions()
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        cropViewAfterActions()
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        cropViewAfterActions()
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        guard cropView?.alpha == 0 else {
            return
        }
        
        let size = self.size(size: scrollView.contentSize, minSize: CGSize.zero, maxSize: cropRectMaxFrame.size)
        
        scrollView.contentInset = centeredInsets(from: size, to: cropRectMaxFrame.size)
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        cropViewAfterActions()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        cropViewAfterActions()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        cropViewAfterActions()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {}

    // MARK: - AKImageCropperCropViewDelegate

    public func cropViewDidTouchCropRect(_ cropView: AKImageCropperCropView,  _ rect: CGRect) {
        cropViewBeforeActions()
    }
    
    public func cropViewDidChangeCropRect(_ cropView: AKImageCropperCropView,  _ rect: CGRect) {
        
        scrollView.contentInset = UIEdgeInsetsMake(
            rect.origin.y,
            rect.origin.x,
            cropView.frame.size.height - rect.maxY, // rect.size.height - rect.origin.y
            cropView.frame.size.width - rect.maxX) // rect.size.width - rect.origin.x
        
        if rect.size.height > scrollView.contentSize.height || rect.size.width > scrollView.contentSize.width {
            
            let fillScaleMultiplier = AKImageCropperUtility.getFillScaleMultiplier(scrollView.contentSize, relativeToSize: rect.size)
            
            scrollView.maximumZoomScale *= fillScaleMultiplier
            scrollView.minimumZoomScale *= fillScaleMultiplier
            scrollView.zoomScale        *= fillScaleMultiplier
        }
    }
    
    public func cropViewDidEndTouchCropRect(_ cropView: AKImageCropperCropView,  _ rect: CGRect) {
        cropViewAfterActions()
    }
}

//  MARK: - AKImageCropperViewDelegate

public protocol AKImageCropperViewDelegate : class {
    
    /**
     
     Tells the delegate that crop frame was changed.
     
     - parameter view : The image cropper view.
     - parameter rect : New crop rectangle origin and size.
     
     */
    
    func imageCropperViewDidChangeCropRect(view: AKImageCropperView, cropRect rect: CGRect)
}

public extension AKImageCropperViewDelegate {
    
    func imageCropperViewDidChangeCropRect(view: AKImageCropperView, cropRect rect: CGRect) {}
}
