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

open class AKImageCropperView: UIView, UIScrollViewDelegate, UIGestureRecognizerDelegate, AKImageCropperCropViewDelegate {
    
    // MARK: Initialization OBJECTS(VIEWS) & theirs parameters
    
    // MARK: ** Rotate view **
    
    fileprivate (set) lazy var rotateView: UIView! = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()
    
    // MARK: ** Scroll view **
    
    open lazy var scrollView: UIScrollView! = {
        let view = UIScrollView()
        view.delegate = self
        view.alwaysBounceVertical = true
        view.alwaysBounceHorizontal = true
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
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

    open var rotatedFrame: CGRect {
        return CGRect(origin: CGPoint.zero, size: revSize(frame.size))
    }
    
    /// Scroll view frame reversed by angle.
    open var scrollViewInsetFrame: CGRect {
        
        //  Current frame reversed by angle
        let rotatedFrame = CGRect(origin: CGPoint.zero, size: revSize(frame.size))

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
            width   : rotatedFrame.size.width - (reversedInsets.left + reversedInsets.right),
            height  : rotatedFrame.size.height - (reversedInsets.top + reversedInsets.bottom))
    }
    
    func updateScrollViewMinMaxZoom() {
        /*
        guard let image = image else {
            return
        }
        
        let minimumZoomScale = AKImageCropperUtility.getFillScaleMultiplier(image.size, relativeToSize: scrollView.frame.size)
        
        scrollView.maximumZoomScale = minimumZoomScale * 1000
        scrollView.minimumZoomScale = minimumZoomScale*/
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
    fileprivate var isDidZoomEnabled: Bool {
        return !(isAnimation || isOverlayCropViewActive)
    }
    
    /**
     
     Show the overlay view with crop rectangle.
     
     - parameter duration: The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them. Default value is 0.
     - parameter options: A mask of options indicating how you want to perform the animations. For a list of valid constants, see UIViewAnimationOptions. Default value is .curveEaseInOut.
     - parameter completion: A block object to be executed when the animation sequence ends. This block has no return value and takes a single Boolean argument that indicates whether or not the animations actually finished before the completion handler was called. If the duration of the animation is 0, this block is performed at the beginning of the next run loop cycle. This parameter may be NULL.
     
     */
    open func showOverlayCropView(animationDuration duration: TimeInterval = 0, options: UIViewAnimationOptions = .curveEaseInOut, completion: ((Bool) -> Void)? = nil) {
        
        
        /*
        guard overlayView != nil && !isOverlayCropViewActive else {
            return
        }*/
        

        
        updateScrollViewSavedVariables()
        
        scrollViewInsets = cropView!.configuraiton.cropRectInsets
        
        
        
        
        
        

        if duration == 0 {
            isAnimation = true
            
            cropView?.alpha = 1
            cropView?.isHidden = false
            
            layoutSubviews()
//            updateScrollViewMinMaxZoom()
            
            isAnimation = false
            isOverlayCropViewActive = true
            
            completion?(true)
            
        } else {
       
            isAnimation = true
            
            isOverlayCropViewActive = true
            

            var contentOffsetXPercentage: CGFloat = 0.0
            if scrollView.contentOffset.x > 0 {
                contentOffsetXPercentage = scrollView.contentOffset.x / (scrollView.contentSize.width - scrollView.frame.size.width)
            }
            
            var contentOffsetYPercentage: CGFloat = 0.0
            if scrollView.contentOffset.y > 0 {
                contentOffsetYPercentage = scrollView.contentOffset.y / (scrollView.contentSize.height - scrollView.frame.size.height)
            }
            

            UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                
                self.layoutSubviews()

                /**
                 
                 Update scroll view content offsets 
                 using active zooming scale and insets.
                 
                 */
                
                self.scrollView.contentOffset.x =
                    self.scrollView.contentInset.left > self.scrollViewInsets.left
                    ? 0
                    : ((self.scrollView.contentSize.width - self.scrollViewInsetFrame.size.width) * contentOffsetXPercentage)
                
                
                self.scrollView.contentOffset.y =
                    self.scrollView.contentInset.top > self.scrollViewInsets.left
                    ? 0
                    : ((self.scrollView.contentSize.height - self.scrollViewInsetFrame.size.height) * contentOffsetYPercentage)
                
                self.scrollView.contentOffset.x -= self.scrollView.contentInset.left
                self.scrollView.contentOffset.y -= self.scrollView.contentInset.top
                
            }, completion: { _ in
                
                self.updateScrollViewSavedVariables()
                
                self.cropView?.alpha = 0
                
                
//                self.cropView?.cropRect = self.cropRect
                self.cropView?.layoutSubviews()
                
                
                
                UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                    
                    self.cropView?.alpha = 1
                    
                    
                    
               
                }, completion: { isFinished in
                    /*
                    self.updateScrollViewMinMaxZoom()
                    self.updateScrollViewSavedVariables()
                    */
                
                    
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
    
    open func hideOverlayCropView(animationDuration duration: TimeInterval = 0, options: UIViewAnimationOptions = .curveEaseInOut, completion: ((Bool) -> Void)? = nil) {
        
        guard cropView != nil || isOverlayCropViewActive else {
            return
        }

        updateScrollViewSavedVariables()
        
        scrollViewInsets = UIEdgeInsets.zero
        
        cancelZoomingToFitTimer()
        
        if duration == 0 {
            
            isAnimation = true
            
            cropView?.alpha = 0
            cropView?.isHidden = true
            
            layoutSubviews()
            
//            updateScrollViewMinMaxZoom()
            
            self.isOverlayCropViewActive = false
            self.isAnimation = false
            
            completion?(true)
        } else {
            
            self.isAnimation = true
            
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                
                self.cropView?.alpha = 0
                
            }, completion: { _ in
                
                self.cropView?.isHidden = true
                
                UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                    
                    self.layoutSubviews()
                    
                }, completion: { isFinished in
                    
                    self.updateScrollViewSavedVariables()
                    
                    self.isOverlayCropViewActive = false
//                    self.layoutSubviews()
                    self.isAnimation = false
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
        

        /**
         
         4. Crop view with crop rectangle
         
         */
        
        cropView = AKImageCropperCropView()
        
        /**
         
         5. Main rotate view container
         
         */
        
        addSubview(rotateView)
        

        /* 
         
         Touch / Release gesture will call follow actions:
         - for zooming to fit
         - showing or hiding grid view
         
         */
        
        /*
        let pressGesture = UILongPressGestureRecognizer(target: self, action: #selector(pressGestureAction(_ :)))
        pressGesture.minimumPressDuration = 0
        pressGesture.cancelsTouchesInView = false
        pressGesture.delegate = self
        addGestureRecognizer(pressGesture)*/
        
        scrollView.addObserver(self, forKeyPath: "frame", options: [.new], context: nil)
        scrollView.addObserver(self, forKeyPath: "contentSize", options: [.new], context: nil)
        scrollView.addObserver(self, forKeyPath: "contentOffset", options: [.new], context: nil)
        scrollView.addObserver(self, forKeyPath: "contentInset", options: [.new], context: nil)
                /*
        scrollView.addObserver(self, forKeyPath: "maximumZoomScale", options: [.new], context: nil)
        scrollView.addObserver(self, forKeyPath: "minimumZoomScale", options: [.new], context: nil)
        scrollView.addObserver(self, forKeyPath: "zoomScale", options: [.new], context: nil)
         */
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        
        
        guard let keyPath = keyPath  else {
            return
        }
        
        switch keyPath {
        case "contentInset":
            
            if let nsRect = change![NSKeyValueChangeKey.newKey] as? NSValue {
                
                 cropView?.matchForegroundToScrollView(scrollView: scrollView)
                
                cropView?.layoutSubviews()
//                foregroundContainerImageView.frame = cropRect
            }
            
        case "frame":
            
            if let nsRect = change![NSKeyValueChangeKey.newKey] as? NSValue {
                cropView?.matchForegroundToScrollView(scrollView: scrollView)
//                foregroundContainerImageView.frame = cropRect
            }
            
        case "contentOffset":
            
            if let nsPoint = change![NSKeyValueChangeKey.newKey] as? NSValue {
                
                cropView?.matchForegroundToScrollView(scrollView: scrollView)
 
                
//                foregroundContainerImageView.frame = cropRect
            
                
                
                
//                overlayScrollView.contentOffset = CGPoint(x: p.x + scrollView.contentInset.left, y: p.y + scrollView.contentInset.top)
                
                
            }
            /*
            overlayScrollView.maximumZoomScale = scrollView.maximumZoomScale
            overlayScrollView.minimumZoomScale = scrollView.minimumZoomScale
            overlayScrollView.zoomScale = scrollView.zoomScale*/
//            overlayScrollView.frame = cropRect
            
        case "contentSize":
            
        
            if let nsSize = change![NSKeyValueChangeKey.newKey] as? NSValue {
//                foregroundImageView.frame.size = nsSize.cgSizeValue
            }

        case "maximumZoomScale":
            
            if let nsFloat = change![NSKeyValueChangeKey.newKey] as? NSNumber {
//                overlayScrollView.maximumZoomScale = CGFloat(nsFloat)
//                print("maximumZoomScale \(CGFloat(nsFloat))")
            }
            
        case "minimumZoomScale":
            
            print("minimumZoomScale")
            
            if let nsFloat = change![NSKeyValueChangeKey.newKey] as? NSNumber {
//                overlayScrollView.minimumZoomScale = CGFloat(nsFloat)
            }
            
        case "zoomScale":
            
            print("zoomScale")
      
            
            if let nsFloat = change![NSKeyValueChangeKey.newKey] as? NSNumber {
//                overlayScrollView.zoomScale = CGFloat(nsFloat)
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
            maxSize : scrollViewInsetFrame.size)
        
        
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
    
        
        if cropView?.alpha == 1 {
            
     
            var fitScaleMultiplier = AKImageCropperUtility.getFitScaleMultiplier(cropRect.size, relativeToSize: scrollViewInsetFrame.size)
            
//            fitScaleMultiplier = 2
            
            
            
            
            
            scrollView.maximumZoomScale     *= fitScaleMultiplier
            scrollView.minimumZoomScale     *= fitScaleMultiplier
            scrollView.zoomScale            *= fitScaleMultiplier
            
            
            let size = CGSize(width: cropRect.size.width * fitScaleMultiplier, height: cropRect.size.height * fitScaleMultiplier)
            
            
            
            
            var center = AKImageCropperUtility.centers(size, relativeToSize: scrollViewInsetFrame.size)
            
            var ins = UIEdgeInsetsMake(
                center.y + scrollViewInsets.top,
                center.x + scrollViewInsets.left,
                center.y + scrollViewInsets.bottom,
                center.x + scrollViewInsets.right)
            
            
      
            scrollView.contentInset = ins
            
            
            
            let savedFitScaleMultiplier = AKImageCropperUtility.getFitScaleMultiplier(scrollViewSaved.frameSize, relativeToSize: scrollViewInsetFrame.size)
            
            print(savedFitScaleMultiplier)
            print(ins)
            
            scrollView.contentOffset.x = (scrollViewSaved.contentOffset.x * savedFitScaleMultiplier) - ins.left
            scrollView.contentOffset.y = (scrollViewSaved.contentOffset.y * savedFitScaleMultiplier) - ins.top
        
        
        
        } else {
            
            
            let fitScaleMultiplier = image == nil
                ? 1
                : AKImageCropperUtility.getFitScaleMultiplier(image!.size, relativeToSize: scrollViewInsetFrame.size)
            
            
            
            scrollView.maximumZoomScale = fitScaleMultiplier * 1000
            scrollView.minimumZoomScale = fitScaleMultiplier
            scrollView.zoomScale        = fitScaleMultiplier * scrollViewSaved.scaleAspectRatio
            
           
        }
        
        
        
        /*
        rotateView.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
        

//        var adjuctOffsets: Bool = true
        
        if isOverlayCropViewActive {
 
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
        
        
   
        */
        
        scrollView?.frame = frame
        
        
        
        
        cropView?.frame = frame
        cropView?.layoutSubviews()   
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

        if size.width < minSize.width {
            size.width = minSize.width
        }
        
        if size.height < minSize.height {
            size.height = minSize.height
        }
        
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
    
    @objc fileprivate func pressGestureAction(_ gesture: UITapGestureRecognizer) {
        
        if gesture.state == .began {
            beganGestureActions()
        } else if gesture.state == .ended || gesture.state == .cancelled {
            endedGestureActions()
        }
    }
    
    fileprivate func beganGestureActions() {
        cropView?.gridVisibility(visible: true)
        cropView?.blurVisibility(visible: false)
        cancelZoomingToFitTimer()
    }
    
    fileprivate func endedGestureActions() {
        updateScrollViewSavedVariables()
        startZoomingToFitTimer()
    }
    
    // MARK: - Zooming to tit
    
    fileprivate var zoomingToFitTimer: Timer?
    
    fileprivate func startZoomingToFitTimer() {
        /*
        cancelZoomingToFitTimer()
        
        guard let zoomingToFitDelay = overlayView?.configuraiton.zoomingToFitDelay else {
            return
        }
        
        zoomingToFitTimer = Timer.scheduledTimer(timeInterval: zoomingToFitDelay, target: self, selector: #selector(zoomToFitAction), userInfo: nil, repeats: false)*/
    }
    
    fileprivate func cancelZoomingToFitTimer() {
        /*
        zoomingToFitTimer?.invalidate()
        zoomingToFitTimer = nil*/
    }
    
    @objc fileprivate func zoomToFitAction() {
        
        updateScrollViewSavedVariables()        

        cropView?.gridVisibility(visible: false)
        cropView?.blurVisibility(visible: true)
        
        UIView.animate(withDuration: self.cropView!.configuraiton.animation.duration, delay: 0, options: self.cropView!.configuraiton.animation.options, animations: {
            
            self.layoutSubviews()
            
        }, completion: { isDone in
            
            self.delegate?.imageCropperViewDidChangeCropRect(view: self, cropRect: self.cropView!.cropRect)
        })
    }
    
    // MARK: - Helper methods
    
    private func revSize(_ size: CGSize) -> CGSize {
        return ((angle / M_PI_2).truncatingRemainder(dividingBy: 2)) == 1 ? CGSize(width: size.height, height: size.width) : size
    }
    
    fileprivate func updateScrollViewSavedVariables() {
        
        scrollViewSaved.scaleAspectRatio = scrollView.zoomScale / scrollView.minimumZoomScale
        
        scrollViewSaved.contentOffset = CGPoint(x: scrollView.contentOffset.x + scrollView.contentInset.left, y: scrollView.contentOffset.y + scrollView.contentInset.top)
        
        
        
        scrollViewSaved.contentSize = scrollView.contentSize
        scrollViewSaved.frameSize = cropRect.size
        
        print(scrollViewSaved.contentOffset)
        

        
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
        

        guard cropView?.alpha == 0 else {
            return
        }
        
        
        let size = self.size(size: scrollView.contentSize, minSize: CGSize.zero, maxSize: scrollViewInsetFrame.size)
        
        var center = AKImageCropperUtility.centers(size, relativeToSize: scrollViewInsetFrame.size)

        var ins = UIEdgeInsetsMake(
            center.y + scrollViewInsets.top,
            center.x + scrollViewInsets.left,
            center.y + scrollViewInsets.bottom,
            center.x + scrollViewInsets.right)
        
        
        
        
        scrollView.contentInset = ins
        
        
//        overlayScrollView.zoomScale = scrollView.zoomScale
        

    }
   
 
    
    
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
//        cropView?.gridVisibility(visible: true)
//        cropView?.blurVisibility(visible: false)
    }
    
    
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
//        cancelZoomingToFitTimer()
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        cancelZoomingToFitTimer()
        
        

    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
//        endedGestureActions()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        endedGestureActions()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        endedGestureActions()
//        updateScrollViewSavedVariables()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
//        cropView?.matchForegroundToScrollView(scrollView: scrollView)
        
        /*
        
        let p = scrollView.contentOffset
        
        let origin = CGPoint(
            x: -(p.x + foregroundContainerImageView.frame.origin.x),
            y: -(p.y + foregroundContainerImageView.frame.origin.y))
        
        foregroundImageView.frame.origin = origin
        foregroundImageView.frame.size = scrollView.contentSize
        
        */
        
        /*
        var c = scrollView.convert(imageView.frame, to: rotateView)
        
        c.origin.y -= scrollView.contentInset.top
        c.origin.x -= scrollView.contentInset.top
        foregroundImageView.frame = c*/
        
        /*
        print(scrollView.contentOffset)
        print(scrollView.contentInset)
        print("  ")
        
        */
        /*
        
        
        
        foregroundContainerImageView.frame = cropRect
        foregroundContainerImageView.frame.origin.y = c.origin.y
        
        
        
        foregroundImageView.frame.size = scrollView.contentSize
        
        
        print(scrollView.convert(imageView.frame, to: rotateView))*/
    }
    
    // MARK: - UIGestureRecognizerDelegate
    /*
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }*/
    
    // MARK: - AKImageCropperCropViewDelegate

    public func cropViewDidTouchCropRect(_ cropView: AKImageCropperCropView,  _ rect: CGRect) {}
    
    public func cropViewDidChangeCropRect(_ cropView: AKImageCropperCropView,  _ rect: CGRect) {
        

        
        
        scrollView.contentInset.top = rect.origin.y
        scrollView.contentInset.left = rect.origin.x
        scrollView.contentInset.bottom = cropView.frame.size.height - rect.size.height - rect.origin.y
        scrollView.contentInset.right = cropView.frame.size.width - rect.size.width - rect.origin.x
        

        
        if rect.size.height > scrollView.contentSize.height || rect.size.width > scrollView.contentSize.width {
            
            let fillScaleMultiplier = AKImageCropperUtility.getFillScaleMultiplier(scrollView.contentSize, relativeToSize: rect.size)
            
            scrollView.maximumZoomScale *= fillScaleMultiplier
            scrollView.minimumZoomScale *= fillScaleMultiplier
            scrollView.zoomScale        *= fillScaleMultiplier
            
        }
        
        
        
        /*
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
        
        updateScrollViewSavedVariables()*/
        
        
    }
    
    public func cropViewDidEndTouchCropRect(_ cropView: AKImageCropperCropView,  _ rect: CGRect) {
        /*
        scrollView.contentOffset.y += rect.origin.y - scrollView.frame.origin.y
        scrollView.contentOffset.x += rect.origin.x - scrollView.frame.origin.x
        
        scrollView.frame = rect

        updateScrollViewSavedVariables()*/
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
