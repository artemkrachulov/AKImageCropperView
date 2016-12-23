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

open class AKImageCropperView: UIView, UIScrollViewDelegate, UIGestureRecognizerDelegate, AKImageCropperOverlayViewDelegate {
    
    // MARK: Initialization OBJECTS(VIEWS) & theirs parameters
    
    // MARK: ** Rotate view **
    
    fileprivate (set) lazy var rotateView: UIView! = {
        let view = UIView()
//        view.backgroundColor = UIColor.blue
        view.clipsToBounds = true
        return view
    }()
    
    // MARK: ** Scroll view **
    
    fileprivate (set) lazy var overlayScrollView: UIScrollView! = {
        let view = UIScrollView()
        view.backgroundColor = UIColor.red
        view.delegate = self
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.clipsToBounds = false
        view.isUserInteractionEnabled = false
        return view
    }()
    
    fileprivate (set) lazy var scrollView: UIScrollView! = {
        let view = UIScrollView()
        view.backgroundColor = UIColor.red
        view.delegate = self
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.clipsToBounds = false
//        view.alpha = 0.5
        return view
    }()
    
    /// Scroll view saved parameters
    private struct ScrollViewSaved {
        
        // Zoom / Minimum Zoom
        var scaleAspectRatio: CGFloat
        
        var contentOffset: CGPoint
        
        var contentSize: CGSize
        
        var frameSize: CGSize
    }
  
    /// Saved parameters (like static) before each layout animation
    private var scrollViewSaved = ScrollViewSaved(
        scaleAspectRatio    : 1.0,
        contentOffset       : CGPoint.zero,
        contentSize         : CGSize.zero,
        frameSize           : CGSize.zero)
    

    /// This property is used for detecting touch areas outside the crop rectangle when overlay view is active.
    private var scrollViewInsets = UIEdgeInsets.zero

    /// Scroll view frame reversed by angle.
    open var scrollViewInsetFrame: CGRect {
        
        //  Current frame reversed by angle
        let reversedFrame = CGRect(origin: CGPoint.zero, size: revSize(frame.size))

        //  Current insets reversed by angle
        var reversedInsets = scrollViewInsets
        
        if angle == M_PI_2 {
            
            reversedInsets.top = scrollViewInsets.right
            reversedInsets.left = scrollViewInsets.top
            reversedInsets.bottom = scrollViewInsets.left
            reversedInsets.right = scrollViewInsets.bottom
            
        } else if angle == M_PI {
            
            reversedInsets.top = scrollViewInsets.bottom
            reversedInsets.left = scrollViewInsets.right
            reversedInsets.bottom = scrollViewInsets.top
            reversedInsets.right = scrollViewInsets.left
            
        } else if angle == M_PI_2 * 3 {
            
            reversedInsets.top = scrollViewInsets.left
            reversedInsets.left = scrollViewInsets.bottom
            reversedInsets.bottom = scrollViewInsets.right
            reversedInsets.right = scrollViewInsets.top
        }
        
        return CGRect(
            x       : reversedInsets.left,
            y       : reversedInsets.top,
            width   : reversedFrame.size.width - (reversedInsets.left + reversedInsets.right),
            height  : reversedFrame.size.height - (reversedInsets.top + reversedInsets.bottom))
    }
    
    func updateScrollViewMinMaxZoom() {
        
        guard let image = image else {
            return
        }
        
        let minimumZoomScale = AKImageCropperUtility.getFillScaleMultiplier(image.size, relativeToSize: scrollView.frame.size)
        
        scrollView.maximumZoomScale = minimumZoomScale * 1000
        scrollView.minimumZoomScale = minimumZoomScale
    }
    
    // MARK: ** Overlay view **
    
    open var overlayView: AKImageCropperOverlayView? {
        didSet {
            
            overlayView?.cropperView = self
            overlayView?.delegate = self
            
            if overlayView != nil && rotateView != nil {
                rotateView.addSubview(overlayView!)
            }
        }
    }
    
  
    /// Determines the overlay view current state. Default is false.
    open var isOverlayViewActive: Bool = false
    
    ///
    fileprivate var isAnimation: Bool = false
    fileprivate var isDidZoomEnabled: Bool {
        return !(isAnimation || isOverlayViewActive)
    }
    
    /**
     
     Show the overlay view with crop rectangle.
     
     - parameter duration: The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them. Default value is 0.
     - parameter options: A mask of options indicating how you want to perform the animations. For a list of valid constants, see UIViewAnimationOptions. Default value is .curveEaseInOut.
     - parameter completion: A block object to be executed when the animation sequence ends. This block has no return value and takes a single Boolean argument that indicates whether or not the animations actually finished before the completion handler was called. If the duration of the animation is 0, this block is performed at the beginning of the next run loop cycle. This parameter may be NULL.
     
     */
    open func showOverlayView(animationDuration duration: TimeInterval = 0, options: UIViewAnimationOptions = .curveEaseInOut, completion: ((Bool) -> Void)? = nil) {
        
        guard overlayView != nil && !isOverlayViewActive else {
            return
        }
        
        updateScrollViewSavedVariables()
        
        scrollViewInsets = overlayView!.configuraiton.cropRectInsets

        if duration == 0 {
            isAnimation = true
            
            overlayView?.alpha = 1
            overlayView?.isHidden = false
            
            layoutSubviews()
//            updateScrollViewMinMaxZoom()
            
            isAnimation = false
            isOverlayViewActive = true
            
            completion?(true)
            
        } else {
       
            isAnimation = true
            
            isOverlayViewActive = true
            
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                
                self.layoutSubviews()
                
            }, completion: { _ in
                
                self.overlayView?.alpha = 0
                self.overlayView?.isHidden = false
                
                UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                    
                    self.overlayView?.alpha = 1
               
                }, completion: { isFinished in
                    
                    self.updateScrollViewMinMaxZoom()
                    self.updateScrollViewSavedVariables()
                    
                
                    
                    self.isAnimation = false
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
    
    open func hideOverlayView(animationDuration duration: TimeInterval = 0, options: UIViewAnimationOptions = .curveEaseInOut, completion: ((Bool) -> Void)? = nil) {
        
        guard overlayView != nil || isOverlayViewActive else {
            return
        }

        updateScrollViewSavedVariables()
        
        scrollViewInsets = UIEdgeInsets.zero
        
        cancelZoomingToFitTimer()
        
        if duration == 0 {
            
            isAnimation = true
            
            overlayView?.alpha = 0
            overlayView?.isHidden = true
            
            layoutSubviews()
            
//            updateScrollViewMinMaxZoom()
            
            self.isOverlayViewActive = false
            self.isAnimation = false
            
            completion?(true)
        } else {
            
            self.isAnimation = true
            
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                
                self.overlayView?.alpha = 0
                
            }, completion: { _ in
                
                self.overlayView?.isHidden = true
                
                UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                    
                    self.layoutSubviews()
                    
                }, completion: { isFinished in
                    
                    self.updateScrollViewSavedVariables()
                    
                    self.isOverlayViewActive = false
//                    self.layoutSubviews()
                    self.isAnimation = false
                    completion?(isFinished)
                })
            })
        }
    }
    
    


    // MARK: ** Image view **
    
    fileprivate (set) lazy var overlayImageView: UIImageView! = {
        let view = UIImageView()
        return view
    }()
    
    
    fileprivate (set) lazy var imageView: UIImageView! = {
        let view = UIImageView()
        view.alpha = 0.5
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
        
        //  Create views layout
//        overlayScrollView.addSubview(overlayImageView)
        
        scrollView.addSubview(imageView)
//        scrollView.alpha = 0
//        rotateView.addSubview(overlayScrollView)
        rotateView.addSubview(scrollView)
        
        overlayView = AKImageCropperOverlayView()
        addSubview(rotateView)
        
        /* 
         
         Touch / Release gesture will call follow actions:
         - for zooming to fit
         - showing or hiding grid view
         
         */
        
        let pressGesture = UILongPressGestureRecognizer(target: self, action: #selector(pressGestureAction(_ :)))
        pressGesture.minimumPressDuration = 0
        pressGesture.cancelsTouchesInView = false
        pressGesture.delegate = self
        addGestureRecognizer(pressGesture)
        /*
        scrollView.addObserver(self, forKeyPath: "frame", options: [.new, .old], context: nil)
        scrollView.addObserver(self, forKeyPath: "contentOffset", options: [.new, .old], context: nil)
        scrollView.addObserver(self, forKeyPath: "contentSize", options: [.new, .old], context: nil)
        scrollView.addObserver(self, forKeyPath: "maximumZoomScale", options: [.new, .old], context: nil)
        scrollView.addObserver(self, forKeyPath: "minimumZoomScale", options: [.new, .old], context: nil)
        scrollView.addObserver(self, forKeyPath: "zoomScale", options: [.new, .old], context: nil)*/
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let keyPath = keyPath  else {
            return
        }
        
        switch keyPath {
        case "frame":
            
            if let nsRect = change![NSKeyValueChangeKey.newKey] as? NSValue {
                overlayScrollView.frame = nsRect.cgRectValue
            }
            
        case "contentOffset":
            
            if let nsPoint = change![NSKeyValueChangeKey.newKey] as? NSValue {
                overlayScrollView.contentOffset = nsPoint.cgPointValue
            }
        
        case "contentSize":
        
            if let nsSize = change![NSKeyValueChangeKey.newKey] as? NSValue {
                overlayScrollView.contentSize = nsSize.cgSizeValue
            }
            
        case "maximumZoomScale":
            
            if let nsFloat = change![NSKeyValueChangeKey.newKey] as? NSNumber {
                overlayScrollView.maximumZoomScale = CGFloat(nsFloat)
                print("maximumZoomScale \(CGFloat(nsFloat))")
            }
            
        case "minimumZoomScale":
            if let nsFloat = change![NSKeyValueChangeKey.newKey] as? NSNumber {
                overlayScrollView.minimumZoomScale = CGFloat(nsFloat)
                print("minimumZoomScale \(CGFloat(nsFloat))")
            }
        case "zoomScale":
            if let nsFloat = change![NSKeyValueChangeKey.newKey] as? NSNumber {
                overlayScrollView.zoomScale = CGFloat(nsFloat)
                print("zoomScale \(CGFloat(nsFloat))")
            }
            
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
            
            overlayImageView.image = image
            overlayImageView.frame.size = image.size
            
            angle = 0
            rotateView.transform = CGAffineTransform.identity
            
            resetScrollViewSavedVariables()
            cancelZoomingToFitTimer()
            
            scrollView.contentSize = image.size
            
            layoutSubviews()
        }
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
        
        let fitScaleMultiplier = AKImageCropperUtility.getFitScaleMultiplier(image.size, relativeToSize: scrollViewInsetFrame.size)
        
        return angle != 0 || fitScaleMultiplier != scrollView.minimumZoomScale || fitScaleMultiplier != scrollView.zoomScale
    }
    
    // MARK: Managing the Delegate
    
    weak open var delegate: AKImageCropperViewDelegate?
    
    // MARK: - Life cycle
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        rotateView.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
        
        let frame = CGRect(origin: CGPoint.zero, size: revSize(self.frame.size))

//        var adjuctOffsets: Bool = true
        
        if isOverlayViewActive {
 
            let fitScaleMultiplier = AKImageCropperUtility.getFitScaleMultiplier(scrollView.frame.size, relativeToSize: scrollViewInsetFrame.size)
            
            scrollView.maximumZoomScale     *= fitScaleMultiplier
            scrollView.minimumZoomScale     *= fitScaleMultiplier
            scrollView.zoomScale            *= fitScaleMultiplier
            /*
            if overlayView!.isHidden {
                
                var toRect = CGRect()
                toRect.size = size(
                    size    : scrollView.contentSize,
                    minSize : CGSize.zero,
                    maxSize : scrollViewInsetFrame.size)
                
                toRect.origin = center(size: toRect.size)
                
                overlayViewDidEndTouchCropRect(overlayView!, toRect)

                
            } else {*/
                
                scrollView.frame.size.width     *= fitScaleMultiplier
                scrollView.frame.size.height    *= fitScaleMultiplier
                scrollView.frame.origin          = center(size: scrollView.frame.size)
            
                let savedFitScaleMultiplier = AKImageCropperUtility.getFitScaleMultiplier(scrollViewSaved.frameSize, relativeToSize: scrollViewInsetFrame.size)
                
                scrollView.contentOffset.x = scrollViewSaved.contentOffset.x * savedFitScaleMultiplier
                scrollView.contentOffset.y = scrollViewSaved.contentOffset.y * savedFitScaleMultiplier
            
//            }
            
            
        } else {
            
            let fitScaleMultiplier = image == nil
                ? 1
                : AKImageCropperUtility.getFitScaleMultiplier(image!.size, relativeToSize: scrollViewInsetFrame.size)
            
            scrollView.maximumZoomScale = fitScaleMultiplier * 1000
            scrollView.minimumZoomScale = fitScaleMultiplier
            scrollView.zoomScale        = fitScaleMultiplier * scrollViewSaved.scaleAspectRatio
            
            
            scrollView.frame.size = size(
                size    : scrollView.contentSize,
                minSize : CGSize(
                    width   : image!.size.width * fitScaleMultiplier,
                    height  : image!.size.height * fitScaleMultiplier),
                maxSize : scrollViewInsetFrame.size)
            scrollView.frame.origin = center(size: scrollView.frame.size)
            
            
            print(scrollView.contentOffset)
            print(scrollViewSaved.contentOffset)
            
            /*
            let savedFitScaleMultiplier = AKImageCropperUtility.getFitScaleMultiplier(scrollViewSaved.frameSize, relativeToSize: scrollViewInsetFrame.size)
            
            print(savedFitScaleMultiplier)
            
            scrollView.contentOffset.x *= savedFitScaleMultiplier
            scrollView.contentOffset.y *= savedFitScaleMultiplier*/
            
            
            /*

            let savedFitScaleMultiplier = AKImageCropperUtility.getFitScaleMultiplier(scrollViewSaved.frameSize, relativeToSize: scrollViewInsetFrame.size)
            
            scrollView.contentOffset.x = scrollViewSaved.contentOffset.x * savedFitScaleMultiplier
            scrollView.contentOffset.y = scrollViewSaved.contentOffset.y * savedFitScaleMultiplier
            */

        }
        
        
   
        
        overlayView?.frame = frame
        overlayView?.cropRect = scrollView.frame
        overlayView?.layoutSubviews()
    }
    

//    fileprivate var showOverlayView: Bool = false
    
    
    func center(size: CGSize) -> CGPoint {
        
        var origin = AKImageCropperUtility.centers(size, relativeToSize: scrollViewInsetFrame.size)
        origin.x += scrollViewInsets.left
        origin.y += scrollViewInsets.top
    
        return origin
    }
    
    func size(size: CGSize, minSize: CGSize, maxSize: CGSize) -> CGSize {
    
        var size = size
        
        if size.width > maxSize.width {
            size.width = maxSize.width
        }
        
        if size.height > maxSize.height {
            size.height = maxSize.height
        }
/*
        if size.width < minSize.width {
            size.width = minSize.width
        }
        
        if size.height < minSize.height {
            size.height = minSize.height
        }*/
        
        return size
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
    
    @objc fileprivate func pressGestureAction(_ gesture: UITapGestureRecognizer) {
        
        if gesture.state == .began {
            beganGestureActions()
        } else if gesture.state == .ended || gesture.state == .cancelled {
            endedGestureActions()
        }
    }
    
    fileprivate func beganGestureActions() {
        overlayView?.gridVisibility(visible: true)
        overlayView?.blurVisibility(visible: false)
        cancelZoomingToFitTimer()
    }
    
    fileprivate func endedGestureActions() {
        updateScrollViewSavedVariables()
        startZoomingToFitTimer()
    }
    
    // MARK: - Zooming to tit
    
    fileprivate var zoomingToFitTimer: Timer?
    
    fileprivate func startZoomingToFitTimer() {
        
        cancelZoomingToFitTimer()
        
        guard let zoomingToFitDelay = overlayView?.configuraiton.zoomingToFitDelay else {
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

        overlayView?.gridVisibility(visible: false)
        overlayView?.blurVisibility(visible: true)
        
        UIView.animate(withDuration: self.overlayView!.configuraiton.animation.duration, delay: 0, options: self.overlayView!.configuraiton.animation.options, animations: {
            
            self.layoutSubviews()
            
        }, completion: { isDone in
            
            self.delegate?.imageCropperViewDidChangeCropRect(view: self, cropRect: self.overlayView!.cropRect)
        })
    }
    
    // MARK: - Helper methods
    
    private func revSize(_ size: CGSize) -> CGSize {
        return ((angle / M_PI_2).truncatingRemainder(dividingBy: 2)) == 1 ? CGSize(width: size.height, height: size.width) : size
    }
    
    fileprivate func updateScrollViewSavedVariables() {

        
        
        scrollViewSaved.scaleAspectRatio = scrollView.zoomScale / scrollView.minimumZoomScale
        scrollViewSaved.contentOffset = scrollView.contentOffset
        scrollViewSaved.contentSize = scrollView.contentSize
        scrollViewSaved.frameSize = scrollView.frame.size
        
        
        print(scrollViewSaved.scaleAspectRatio)
        print(scrollViewSaved.contentOffset)
        print(scrollViewSaved.contentSize)
        print(scrollViewSaved.frameSize)
        print(" ")
        
    }
    
    fileprivate func resetScrollViewSavedVariables() {
        scrollViewSaved.scaleAspectRatio = 1.0
        scrollViewSaved.contentOffset = CGPoint.zero
        scrollViewSaved.contentSize = CGSize.zero
        scrollViewSaved.frameSize = CGSize.zero
    }
    
    // MARK: - UIScrollViewDelegate
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        
        return scrollView.subviews.first!
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if isDidZoomEnabled {
//            updateScrollViewSavedVariables()
            scrollViewSaved.frameSize = scrollView.frame.size
            scrollViewSaved.scaleAspectRatio = scrollView.zoomScale / scrollView.minimumZoomScale
            layoutSubviews()
        }
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        overlayView?.gridVisibility(visible: true)
        overlayView?.blurVisibility(visible: false)
    }
    
    
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        cancelZoomingToFitTimer()
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        cancelZoomingToFitTimer()
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        endedGestureActions()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        endedGestureActions()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        endedGestureActions()
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - AKImageCropperOverlayViewDelegate

    public func overlayViewDidTouchCropRect(_ overlayView: AKImageCropperOverlayView,  _ rect: CGRect) {}
    
    public func overlayViewDidChangeCropRect(_ overlayView: AKImageCropperOverlayView,  _ rect: CGRect) {
        
        let deltaY = scrollView.frame.origin.y - scrollView.contentOffset.y
        let deltaX = scrollView.frame.origin.x - scrollView.contentOffset.x

        if rect.origin.y < deltaY {
            
            scrollView.contentOffset.y = 0
            scrollView.frame = rect
        }
        
        if rect.origin.x < deltaX {
            
            scrollView.contentOffset.x = 0
            scrollView.frame = rect
        }

        if rect.maxY > deltaY + scrollView.contentSize.height || rect.maxX > deltaY + scrollView.contentSize.width {
            
            scrollView.frame = rect
        }
      
        if rect.size.height > scrollView.contentSize.height || rect.size.width > scrollView.contentSize.width {
            
            let fillScaleMultiplier = AKImageCropperUtility.getFillScaleMultiplier(scrollView.contentSize, relativeToSize: rect.size)
            
            scrollView.maximumZoomScale *= fillScaleMultiplier
            scrollView.minimumZoomScale *= fillScaleMultiplier
            scrollView.zoomScale *= fillScaleMultiplier
        }
        
        delegate?.imageCropperViewDidChangeCropRect(view: self, cropRect: rect)
        
        updateScrollViewSavedVariables()
    }
    
    public func overlayViewDidEndTouchCropRect(_ overlayView: AKImageCropperOverlayView,  _ rect: CGRect) {
        
        scrollView.contentOffset.y += rect.origin.y - scrollView.frame.origin.y
        scrollView.contentOffset.x += rect.origin.x - scrollView.frame.origin.x
        
        scrollView.frame = rect

        updateScrollViewSavedVariables()
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
