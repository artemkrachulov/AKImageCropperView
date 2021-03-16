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

fileprivate let halfPiValue: Double = Double.pi / 2
fileprivate let piValue: Double = Double.pi

open class AKImageCropperView: UIView, UIScrollViewDelegate, UIGestureRecognizerDelegate, AKImageCropperOverlayViewDelegate {
    
    /** Current rotation angle */
    
    fileprivate var angle: Double = 0.0
    
    /** Scroll view minimum edge insets (current value) */
    
    fileprivate var minEdgeInsets: UIEdgeInsets = .zero
    
    /** Reversed frame direct to current rotation angle */
    
    fileprivate var reversedRect: CGRect {
        return CGRect(
            origin  : .zero,
            size    : ((angle / halfPiValue).truncatingRemainder(dividingBy: 2)) == 1
                ? CGSize(width: frame.size.height, height: frame.size.width)
                : frame.size)
    }
    
    /** Reversed minimum edge insets direct to current rotation angle */
    
    fileprivate var reversedEdgeInsets: UIEdgeInsets {
        
        var newEdgeInsets: UIEdgeInsets
        
        switch angle {
        case halfPiValue:
            newEdgeInsets = UIEdgeInsets(
                top: minEdgeInsets.right,
                left: minEdgeInsets.top,
                bottom: minEdgeInsets.left,
                right: minEdgeInsets.bottom)
        case piValue:
            newEdgeInsets = UIEdgeInsets(
                top: minEdgeInsets.bottom,
                left: minEdgeInsets.right,
                bottom: minEdgeInsets.top,
                right: minEdgeInsets.left)
        case halfPiValue * 3:
            newEdgeInsets = UIEdgeInsets(
                top: minEdgeInsets.left,
                left: minEdgeInsets.bottom,
                bottom: minEdgeInsets.right,
                right: minEdgeInsets.top)
        default:
            newEdgeInsets = minEdgeInsets
        }
        
        return newEdgeInsets
    }
    
    /** Reversed frame + edgeInsets direct to current rotation angle */
    
    var reversedFrameWithInsets: CGRect {
        return reversedRect.inset(by: reversedEdgeInsets)
    }
    
    // MARK: -
    // MARK: ** Saved properties **
    
    fileprivate struct SavedProperty {
        
        var scaleAspectRatio: CGFloat!
        var contentOffset: CGPoint!
        var contentOffsetPercentage: CGPoint!
        var cropRectSize: CGSize!
        
        init() {
            scaleAspectRatio = 1.0
            contentOffset = .zero
            contentOffsetPercentage = .zero
            cropRectSize = .zero
        }
        
        mutating func save(scrollView: AKImageCropperScrollView) {
            
            scaleAspectRatio = scrollView.zoomScale / scrollView.minimumZoomScale
            
            contentOffset = CGPoint(
                x: scrollView.contentOffset.x + scrollView.contentInset.left,
                y: scrollView.contentOffset.y + scrollView.contentInset.top)

            let contentSize = CGSize(
                width   : (scrollView.contentSize.width - scrollView.visibleRect.width).ic_roundTo(precision: 3),
                height  : (scrollView.contentSize.height - scrollView.visibleRect.height).ic_roundTo(precision: 3))

            contentOffsetPercentage = CGPointPercentage(
                x: (contentOffset.x > 0 && contentSize.width != 0)
                    ? ic_round(x: contentOffset.x / contentSize.width, multiplier: 0.005)
                    : 0,
                y: (contentOffset.y > 0 && contentSize.height != 0)
                    ? ic_round(x: contentOffset.y / contentSize.height, multiplier: 0.005)
                    : 0)
            
            cropRectSize = scrollView.visibleRect.size
        }
    }
    
    /** Saved Scroll View parameters before complex layout animation */
    
    fileprivate var savedProperty = SavedProperty()
    
    // MARK: Accessing the Displayed Images
    
    /** The image displayed in the image cropper view. Default is nil. */
    
    open var image: UIImage? {
        didSet {
            
            guard let image = image else {
                return
            }
            
            scrollView.image = image
            overlayView?.image = image
            
            reset()
        }
    }
    
    /** Cropperd image in the specified crop rectangle */
    
    open var croppedImage: UIImage? {
        return image?.ic_imageInRect(scrollView.scaledVisibleRect)?.ic_rotateByAngle(angle)
    }
    
    // MARK: States
    
    /** Returns the image edited state flag. */
    
    open var isEdited: Bool {
        
        guard let image = image else {
            return false
        }

        let fitScaleMultiplier = ic_CGSizeFitScaleMultiplier(image.size, relativeToSize: reversedFrameWithInsets.size)
        
        return angle != 0 || fitScaleMultiplier != scrollView.minimumZoomScale || fitScaleMultiplier != scrollView.zoomScale
    }
    
    /** Determines the overlay view current state. Default is false. */
    
    open private(set) var isOverlayViewActive: Bool = false
    
    fileprivate var layoutByImage: Bool = true
    
    /** Сompletion blocker. */
    
    fileprivate var isAnimation: Bool = false
    
    // MARK: Managing the Delegate
    
    /** The delegate of the cropper view object. */
    
    weak open var delegate: AKImageCropperViewDelegate?

    // MARK: - 
    // MARK: ** Initialization OBJECTS(VIEWS) & theirs parameters **
    
    // MARK: Rotate view
    
    fileprivate lazy var rotateView: UIView! = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()
    
    // MARK: Scroll view

    var scrollView: AKImageCropperScrollView!
    
    // MARK: Overlay Crop view
    
    open var overlayView: AKImageCropperOverlayView? {
        willSet  {
            
            if overlayView != nil {
                overlayView?.removeFromSuperview()
            }
            
            if newValue != nil {
                newValue?.delegate = self
                newValue?.cropperView = self
                rotateView.addSubview(newValue!)
            }
            
            layoutSubviews()
        }
    }
    
    // MARK: - Initializing an Image Cropper View
    
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
     
     - Parameter image: The initial image to display in the image cropper view.
     */
    
    public init(image: UIImage?) {
        super.init(frame:CGRect.zero)
        
        initialize()
        
        self.image = image
    }
    
    fileprivate func initialize() {
        
        /*
         Create views layout.
         Step by step
         
         1. Scroll view ‹‹ Image view
         */

        scrollView = AKImageCropperScrollView()
        scrollView.delegate = self
        rotateView.addSubview(scrollView)
        
        /* 2. Overlay view with crop rectangle */
        
        overlayView = AKImageCropperOverlayView()
        
        /* 3. Rotate view */
        
        addSubview(rotateView)
        
        /**
         Add Observers
         To controll all parameters changing and pass them to foreground image view
         */
        
        initObservers()
        
        let pressGesture = UILongPressGestureRecognizer(target: self, action: #selector(pressGestureAction(_ :)))
        pressGesture.minimumPressDuration = 0
        pressGesture.cancelsTouchesInView = false
        pressGesture.delegate = self
        addGestureRecognizer(pressGesture)
    }
    
    @objc fileprivate func pressGestureAction(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .began {
            beforeInteraction()
        } else if gesture.state == .cancelled || gesture.state == .ended {
            afterInteraction()
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
 
    deinit {
        removeObservers()
        
        #if AKImageCropperViewDEBUG
            print("deinit AKImageCropperView")
        #endif
    }
    
    // MARK: - Observe Scroll view values
    
    fileprivate func initObservers() {
        for forKeyPath in ["contentOffset", "contentSize"] {
            scrollView.addObserver(self, forKeyPath: forKeyPath, options: [.new, .old], context: nil)
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let keyPath = keyPath else {
            return
        }
        
        switch keyPath {
        case "contentOffset":
            if let _ = change![NSKeyValueChangeKey.newKey] {
                 overlayView?.matchForegroundToBackgroundScrollViewOffset()
            }
        case "contentSize":
            if let _ = change![NSKeyValueChangeKey.newKey] {
                overlayView?.matchForegroundToBackgroundScrollViewSize()
            }
        default: ()
        }
    }
    
    fileprivate func removeObservers() {
        for forKeyPath in ["contentOffset", "contentSize"] {
            scrollView.removeObserver(self, forKeyPath: forKeyPath)
        }
    }
    
    // MARK: - Life cycle
    
    override open func layoutSubviews() {
        super.layoutSubviews()
     
        layoutSubviews(byImage: layoutByImage)
    }
    
    func layoutSubviews(byImage: Bool) {
        
        rotateView.frame = CGRect(origin: .zero, size: self.frame.size)
        
        let frame = reversedRect
        
        let reversedFrameWithInsetsSize = reversedFrameWithInsets.size
        
        if byImage {
            
            /* Zoom */
            
            let fitScaleMultiplier = image == nil
                ? 1
                : ic_CGSizeFitScaleMultiplier(image!.size, relativeToSize: reversedFrameWithInsetsSize)
            
            
            scrollView.maximumZoomScale = fitScaleMultiplier * 1000
            scrollView.minimumZoomScale = fitScaleMultiplier
            scrollView.zoomScale = fitScaleMultiplier * savedProperty.scaleAspectRatio
            
        } else {
            
            /* Zoom */
            
            let fitScaleMultiplier = ic_CGSizeFitScaleMultiplier(scrollView.visibleRect.size, relativeToSize: reversedFrameWithInsetsSize)
            
            scrollView.maximumZoomScale *= fitScaleMultiplier
            scrollView.minimumZoomScale *= fitScaleMultiplier
            scrollView.zoomScale *= fitScaleMultiplier
            
            /* Content inset */
            
            var size: CGSize
            
            if overlayView?.alpha == 1 {
                
                size = CGSize(
                    width   : scrollView.visibleRect.size.width * fitScaleMultiplier,
                    height  : scrollView.visibleRect.size.height * fitScaleMultiplier)
                
            } else {
                
                size = ic_CGSizeFits(scrollView.contentSize, minSize: .zero, maxSize: reversedFrameWithInsetsSize)
            }
            
            scrollView.contentInset = centeredInsets(from: size, to: reversedFrameWithInsetsSize)
            
            /* Content offset */
            
            let savedFitScaleMultiplier = ic_CGSizeFitScaleMultiplier(savedProperty.cropRectSize, relativeToSize: reversedFrameWithInsetsSize)
            
            var contentOffset = CGPoint(
                x: savedProperty.contentOffset.x * savedFitScaleMultiplier,
                y: savedProperty.contentOffset.y * savedFitScaleMultiplier)
            
            contentOffset.x -= scrollView.contentInset.left
            contentOffset.y -= scrollView.contentInset.top
            
            scrollView.contentOffset = contentOffset
        }
        
        scrollView.frame = frame
        
        overlayView?.frame = frame
        overlayView?.cropRect = scrollView.visibleRect
        overlayView?.layoutSubviews()
    }

    // MARK: -
    // MARK: ** Actions **
    
    // MARK: Overlay actions
    
    /**
     Show the overlay view with crop rectangle.
     
     - Parameter duration: The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them. Default value is 0.
     
     - Parameter options: A mask of options indicating how you want to perform the animations. For a list of valid constants, see UIViewAnimationOptions. Default value is .curveEaseInOut.
     
     - Parameter completion: A block object to be executed when the animation sequence ends. This block has no return value and takes a single Boolean argument that indicates whether or not the animations actually finished before the completion handler was called. If the duration of the animation is 0, this block is performed at the beginning of the next run loop cycle. This parameter may be NULL.
     */
    
    open func showOverlayView(animationDuration duration: TimeInterval = 0, options: UIView.AnimationOptions = .curveEaseInOut, completion: ((Bool) -> Void)? = nil) {
        
        guard let image = image, let overlayView = overlayView, !isOverlayViewActive && !isAnimation else {
            return
        }
        
        minEdgeInsets = overlayView.configuraiton.cropRectInsets
        savedProperty.save(scrollView: scrollView)
        cancelZoomingTimer()
        
        let _animations: () -> Void = {
            
            self.layoutSubviews()
            
            // Update scroll view content offsets using active zooming scale and insets.
            
            self.scrollView.contentOffset = self.contentOffset(from: self.savedProperty.contentOffsetPercentage)
        }
        
        let _completion: (Bool) -> Void = { isFinished in
            
            // Update zoom relative to crop rext
            
            let fillScaleMultiplier = ic_CGSizeFillScaleMultiplier(image.size, relativeToSize: overlayView.cropRect.size)
            
            self.scrollView.maximumZoomScale = fillScaleMultiplier * 1000
            self.scrollView.minimumZoomScale = fillScaleMultiplier
            
            /* */
            
            self.isAnimation = false
            self.isOverlayViewActive = true
            
            completion?(isFinished)
        }
        
        /* Show */
        
        layoutByImage = false
        
        isAnimation = true
        
        if duration == 0 {
            _animations()
            overlayView.alpha = 1
            _completion(true)
        } else {
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: _animations, completion: { _ in
                UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                    overlayView.alpha = 1
                }, completion: _completion)
            })
        }
    }
    
    /**
     Hide the overlay view with crop rectangle.
     
     - Parameter duration: The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them. Default value is 0.
     
     - Parameter options: A mask of options indicating how you want to perform the animations. For a list of valid constants, see UIViewAnimationOptions. Default value is .curveEaseInOut.
     
     - Parameter completion: A block object to be executed when the animation sequence ends. This block has no return value and takes a single Boolean argument that indicates whether or not the animations actually finished before the completion handler was called. If the duration of the animation is 0, this block is performed at the beginning of the next run loop cycle. This parameter may be NULL.
     */
    
    open func hideOverlayView(animationDuration duration: TimeInterval = 0, options: UIView.AnimationOptions = .curveEaseInOut, completion: ((Bool) -> Void)? = nil) {
        
        guard let image = image, let overlayView = overlayView, isOverlayViewActive && !isAnimation else {
            return
        }
        
        minEdgeInsets = .zero
        savedProperty.save(scrollView: scrollView)
        cancelZoomingTimer()
   
        isAnimation = true
        
        let _animations: () -> Void = {
            
            self.layoutSubviews()
            
            /**
             Update scroll view content offsets
             using active zooming scale and insets.
             */
            
            self.scrollView.contentOffset = self.contentOffset(from: self.savedProperty.contentOffsetPercentage)
        }
        
        let _completion: (Bool) -> Void = { isFinished in

            // Update zoom relative to crop rext
            
            let fitScaleMultiplier = ic_CGSizeFitScaleMultiplier(image.size, relativeToSize: self.reversedFrameWithInsets.size)
 
            self.scrollView.maximumZoomScale = fitScaleMultiplier * 1000
            self.scrollView.minimumZoomScale = fitScaleMultiplier
            
            /* */
            
            self.isAnimation = false
            self.isOverlayViewActive = false
            self.layoutByImage = false
            
            completion?(isFinished)
        }
        
        if duration == 0 {
            overlayView.alpha = 0
            _animations()
            _completion(true)
        } else {
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                overlayView.alpha = 0
            }, completion: { _ in
                UIView.animate(withDuration: duration, delay: 0, options: options, animations: _animations, completion: _completion)
            })
        }
    }
    
    // MARK: Rotate
    
    /**
     Rotate the image on the angle in multiples of 90 degrees (M_PI_2).
     
     - Parameter angle: Rotation angle. The angle a multiple of 90 degrees (M_PI_2).
     
     - Parameter duration: The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them. Default value is 0.
     
     - Parameter options: A mask of options indicating how you want to perform the animations. For a list of valid constants, see UIViewAnimationOptions. Default value is .curveEaseInOut.
     
     - Parameter completion: A block object to be executed when the animation sequence ends. This block has no return value and takes a single Boolean argument that indicates whether or not the animations actually finished before the completion handler was called. If the duration of the animation is 0, this block is performed at the beginning of the next run loop cycle. This parameter may be NULL.
     */
    
    open func rotate(_ angle: Double, withDuration duration: TimeInterval = 0, options: UIView.AnimationOptions = .curveEaseInOut, completion: ((Bool) -> Void)? = nil) {
        
        guard angle.truncatingRemainder(dividingBy: halfPiValue) == 0 else {
            return
        }
        
        self.angle = angle
        savedProperty.save(scrollView: scrollView)
        
        let _animations: () -> Void = {
            
            self.rotateView.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
            self.layoutSubviews()
        }
        
        let _completion: (Bool) -> Void = { isFinished in
            completion?(isFinished)
        }
        
        if duration == 0 {
            _animations()
            _completion(true)
        } else {
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: _animations, completion: _completion)
        }
    }
    
    // MARK: Reset
    
    /**
     Return Cropper view to the initial state.
     
     - Parameter duration: The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them. Default value is 0.
     
     - Parameter options: A mask of options indicating how you want to perform the animations. For a list of valid constants, see UIViewAnimationOptions. Default value is .curveEaseInOut.
     
     - Parameter completion: A block object to be executed when the animation sequence ends. This block has no return value and takes a single Boolean argument that indicates whether or not the animations actually finished before the completion handler was called. If the duration of the animation is 0, this block is performed at the beginning of the next run loop cycle. This parameter may be NULL.
     */
    
    open func reset(animationDuration duration: TimeInterval = 0, options: UIView.AnimationOptions = .curveEaseInOut, completion: ((Bool) -> Void)? = nil) {
        
        guard !isAnimation else {
            return
        }

        savedProperty = SavedProperty()
        angle = 0
        cancelZoomingTimer()
        
        let _animations: () -> Void = {
            
            self.rotateView.transform = CGAffineTransform.identity
            
            let _layoutByImage = self.layoutByImage
            self.layoutByImage = true
            self.layoutSubviews()
            self.layoutByImage = _layoutByImage
            
        }
        
        let _completion: (Bool) -> Void = { isFinished in
            
            self.isAnimation = false
            completion?(isFinished)
        }
        
        isAnimation = true
        if duration == 0 {
            _animations()
            _completion(true)
        } else {
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: _animations, completion: _completion)
        }
    }

    // MARK: - Edge insets zooming
    
    fileprivate var zoomingTimer: Timer?
    
    fileprivate func startZoomingTimer() {
        
        guard let overlayView = overlayView else {
            return
        }

        cancelZoomingTimer()
        
        zoomingTimer = Timer.scheduledTimer(timeInterval: overlayView.configuraiton.zoomingToFitDelay, target: self, selector: #selector(zoomAction), userInfo: nil, repeats: false)
    }
    
    @objc fileprivate func zoomAction() {
        
        guard let overlayView = overlayView else {
            return
        }
        
        savedProperty.save(scrollView: scrollView)
        
        overlayView.showGrid(false)
        overlayView.showOverlayBlur(true)

        UIView.animate(withDuration: overlayView.configuraiton.animation.duration, delay: 0, options: overlayView.configuraiton.animation.options, animations: {
            self.layoutSubviews()
        })
    }
    
    fileprivate func cancelZoomingTimer() {
        zoomingTimer?.invalidate()
        zoomingTimer = nil
    }
    
    // MARK: - After interaction actions    
    
    fileprivate func beforeInteraction() {
        
        guard let overlayView = overlayView, overlayView.alpha == 1.0  else {
            return
        }
        
        cancelZoomingTimer()
        
        overlayView.showGrid(true)
        overlayView.showOverlayBlur(false)
    }
    
    fileprivate func afterInteraction() {
        
        guard let overlayView = overlayView, overlayView.alpha == 1.0  else {
            return
        }
        
        startZoomingTimer()

        savedProperty.save(scrollView: scrollView)
    }
    
    // MARK: - Helper methods
    
    private func centeredInsets(from size: CGSize, to relativeSize: CGSize) -> UIEdgeInsets {
        
        let center = ic_CGPointCenters(size, relativeToSize: relativeSize)
        
        // Fix insets direct to orientation
        
        return UIEdgeInsets(
            top: center.y + minEdgeInsets.top,
            left: center.x + minEdgeInsets.left,
            bottom: center.y + minEdgeInsets.bottom,
            right: center.x + minEdgeInsets.right)
    }
    
    private func contentOffset(from savedContentOffsetPercentage: CGPointPercentage) -> CGPoint {

        var contentOffset = CGPoint(
            x: scrollView.contentInset.left > minEdgeInsets.left
                ? 0
                : ((scrollView.contentSize.width - reversedFrameWithInsets.size.width) * savedContentOffsetPercentage.x),
            y: scrollView.contentInset.top > minEdgeInsets.left
                ? 0
                : ((scrollView.contentSize.height - reversedFrameWithInsets.size.height) * savedContentOffsetPercentage.y))
        
        contentOffset.x -= scrollView.contentInset.left
        contentOffset.y -= scrollView.contentInset.top
        
        return contentOffset
    }
    
    //  MARK: - AKImageCropperOverlayViewDelegate
    
    func cropperOverlayViewDidChangeCropRect(_ view: AKImageCropperOverlayView, _ cropRect: CGRect) {
        
        scrollView.contentInset = UIEdgeInsets(
            top: cropRect.origin.y,
            left: cropRect.origin.x,
            bottom: view.frame.size.height - cropRect.size.height - cropRect.origin.y,
            right: view.frame.size.width - cropRect.size.width - cropRect.origin.x)
        
        if cropRect.size.height > scrollView.contentSize.height || cropRect.size.width > scrollView.contentSize.width {
            
            let fillScaleMultiplier = ic_CGSizeFillScaleMultiplier(scrollView.contentSize, relativeToSize: cropRect.size)
            
            scrollView.maximumZoomScale *= fillScaleMultiplier
            scrollView.minimumZoomScale *= fillScaleMultiplier
            scrollView.zoomScale        *= fillScaleMultiplier
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {        
        return scrollView.subviews.first
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        guard layoutByImage else {
            return
        }
  
        let size = ic_CGSizeFits(scrollView.contentSize, minSize: .zero, maxSize: reversedFrameWithInsets.size)
        
        scrollView.contentInset = centeredInsets(from: size, to: reversedFrameWithInsets.size)
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        beforeInteraction()
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        afterInteraction()
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        beforeInteraction()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        afterInteraction()
    }
}

//  MARK: - AKImageCropperViewDelegate

public protocol AKImageCropperViewDelegate : AnyObject {
    
    /**
     Tells the delegate that crop frame was changed.
     
     - Parameter view : The image cropper view.
     - Parameter rect : New crop rectangle origin and size.
     */
    
    func imageCropperViewDidChangeCropRect(view: AKImageCropperView, cropRect rect: CGRect)
}

public extension AKImageCropperViewDelegate {    
    func imageCropperViewDidChangeCropRect(view: AKImageCropperView, cropRect rect: CGRect) {}
}
