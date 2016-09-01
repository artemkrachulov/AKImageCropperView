//
//  AKImageCropperView.swift
//  AKImageCropper
//  GitHub: https://github.com/artemkrachulov/AKImageCropper
//
//  Created by Artem Krachulov.
//  Copyright (c) 2016 Artem Krachulov. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//
// Hierarchy
//
//  - AKImageCropperView  - - - - - - - - - - - - - - - - - - - - - - -
// |   - Aspect View  - - - - - - - - - - - - - - - - - - - - - - - -  |
// |  |   - Touch View  -   - Overlay View  -   - - Scroll View - -  | |
// |  |  |               | |                 | |  - Image View  -  | | |
// |  |  |               | |                 | | |               | | | |
// |  |  |               | |                 | | |               | | | |
// |  |  |               | |                 | | |               | | | |
// |  |  |               | |                 | |  - - - - - - - -  | | |
// |  |   - - - - - - - -   - - - - - - - - -   - - - - - - - - - -  | |
// |   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -   |
//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
//  ver. 0.1
//

import UIKit

//  MARK: - AKImageCropperViewDelegate

@objc protocol AKImageCropperViewDelegate {
  optional func cropRectChanged(rect: CGRect)
}

/// AKImageCropper is cropping class for iOS devices. Has many settings for flexible integration into your project.
class AKImageCropperView: UIView {

  //  MARK: - Accessing the Images

  /// The image displayed in the cropper view.
  var image: UIImage? {
    didSet {
      
      cropRectSaved = nil
      
      imageView.image = image
      
      scrollView.zoomScale = 1
      scrollView.contentSize = image!.size
      
      imageView.frame.size = image!.size
      
      layoutSubviews()
    }
  }
  
  /// The image cropped from specified rectangle. If rectangle not set property will return current image visible in the cropper view.
  var croppedImage: UIImage? {
    let imageRect = cropRectScaled
    
    let rect = CGRectMake(CGFloat(Int(imageRect.origin.x)), CGFloat(Int(imageRect.origin.y)), CGFloat(Int(imageRect.size.width)), CGFloat(Int(imageRect.size.height)))
    
    return AKImageCropperUtility.imageInRect(rect, fromImage: image!)
  }
  
  //  MARK: - Crop rectangle
  
  /// Returns crop rectangle frame, measured in points. If overlay view not active - crop rectangle will return visbible image size.
  var cropRect: CGRect {
    return cropRectSaved ?? CGRect(origin: CGPointZero, size: scrollView.frame.size)
  }

  /// Returns crop rectangle frame translated with scroll view zoom and offset factor, measured in points.
  var cropRectScaled: CGRect {
    return overlayIsActive ?
      CGRectMake((scrollView.contentOffset.x + cropRect.origin.x) / scrollView.zoomScale,
                 (scrollView.contentOffset.y + cropRect.origin.y) / scrollView.zoomScale,
                 cropRect.size.width / scrollView.zoomScale,
                 cropRect.size.height / scrollView.zoomScale) :
      CGRectMake(scrollView.contentOffset.x / scrollView.zoomScale,
                 scrollView.contentOffset.y / scrollView.zoomScale,
                 scrollView.frame.size.width / scrollView.zoomScale,
                 scrollView.frame.size.height / scrollView.zoomScale)
  }
  
  private var cropRectSaved: CGRect?
  
  //  MARK: - Animating overlay view
  
  
  /// Presents the overlay view.
  ///
  ///   - Parameter animated: Pass true to animate the transition.
  ///   - Parameter completion:  The block to execute after the overlay view is presented. This block has no return value and takes no parameters. You may specify `nil` for this parameter.
  func showOverlayView(animated: Bool, completion: (() -> Void)?) {
    
    // Update offset
    scrollViewOffset = configuration.touchArea / 2
    
    viewsScaleTransition(animated) { (complete) in
      if complete {
        self.overlayView.hidden = false
        
        if animated {
          UIView.animateWithDuration(self.configuration.overlay.animationDuration,
                                     animations: {
                                      self.overlayView.alpha = 1
            }, completion: { (complete) in
              if complete {
                self.overlayIsActive = true
                completion?()
              }
          })
        } else {
          self.overlayView.alpha = 1
          self.overlayIsActive = true
          
          completion?()
        }
      }
    }
  }
  
  /// Presents the overlay view with crop rectangle.
  ///
  ///   - Parameter animated: Pass true to animate the transition.
  ///   - Parameter cropRect: The crop rectangle, measured in points. The origin of the frame is relative to the overlay view. If you may specify `nil` for this parameter, crop rectangle will have size that equal to the scroll view and `CGPointZero` origin coordinates.
  ///   - Parameter completion:  The block to execute after the overlay view is presented. This block has no return value and takes no parameters. You may specify `nil` for this parameter.
  func showOverlayView(animated: Bool, withCropRect rect: CGRect, completion: (() -> Void)?) {
    showOverlayView(animated) {
      self.cropRect(rect)
    }
  }
  
  /// Dismisses the overlay view.
  ///
  /// - Parameter flag : Pass true to animate the transition.
  /// - Parameter completion : The block to execute after the Overlay view is dismissed. This block has no return value and takes no parameters. You may specify `nil` for this parameter.
  func hideOverlayView(animated: Bool, completion: (() -> Void)?) {
    
    // Reset offset
    scrollViewOffset = 0.0
    
    func scaleOutViews() {
      viewsScaleTransition(animated) { (complete) in
        if complete {
          self.overlayIsActive = false
          completion?()
        }
      }
    }
    
    if animated {
      UIView.animateWithDuration(configuration.overlay.animationDuration,
                                 animations: { () -> Void in
                                  self.overlayView.alpha = 0
        }
      ) { (complete) -> Void in
        if complete {
          scaleOutViews()
        }
      }
    } else {
      self.overlayView.alpha = 0
      scaleOutViews()
    }
  }
  
  //  MARK: - Configuration
  
  /// Struct with all confuguration options for crop rectangle and overlay view presented in `AKImageCropperConfiguration` struct.
  var configuration = AKImageCropperConfiguration()
  
  private var minimumSize: CGSize { return configuration.cropRect.minimumSize }
  private var cornerOffset: CGFloat { return configuration.cropRect.cornerOffset }

  //  MARK: - Accessing the Delegate
  
  /// A cropper view delegate responds to draw crop rectangle.
  weak var cropRectDelegate: AKImageCropperCropRectDelegate?
  
  /// A cropper view delegate responds to editing-related messages from the crop rectangle.
  weak var delegate: AKImageCropperViewDelegate?

  //  MARK:   Other private
  
  /// Returns a boolean value that determines Overaly view state in current moment.
  private (set) var overlayIsActive = false
  
  /// Offset dx / dy when overlay is active or not
  private var scrollViewOffset: CGFloat = 0.0
  
  //  MARK: - Objects
  
  private (set) lazy var aspectView: UIView! = {
    let aspectView = UIView()
    aspectView.backgroundColor = UIColor.clearColor()
    aspectView.clipsToBounds = false
    return aspectView
  }()
  
  private lazy var touchView: AKImageCropperTouchView! = {
    let touchView = AKImageCropperTouchView()
    touchView.backgroundColor = UIColor.clearColor()
    touchView.delegate = self
    touchView.cropperView = self
    return touchView
  }()
  
  private lazy var overlayView: AKImageCropperOverlayView! = {
    let overlayView = AKImageCropperOverlayView()
    overlayView.backgroundColor = UIColor.clearColor()
    overlayView.hidden = true
    overlayView.alpha = 0
    overlayView.clipsToBounds = false
    overlayView.cropperView = self
    return overlayView
  }()
  
  private (set) lazy var scrollView: AKImageCropperScollView! = {
    let scrollView = AKImageCropperScollView()
    scrollView.backgroundColor = UIColor.clearColor()
    scrollView.delegate = self
    scrollView.clipsToBounds = true
    scrollView.minimumZoomScale = 0.05
    scrollView.maximumZoomScale = 2
    return scrollView
  }()
  
  private (set) lazy var imageView: UIImageView! = {
    let imageView = UIImageView()
    imageView.backgroundColor = UIColor.clearColor()
    imageView.userInteractionEnabled = true
    return imageView
  }()
  
  //  MARK: - Initialization
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initViews()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initViews()
  }
  
  init(image: UIImage?) {
    super.init(frame:CGRectZero)
    initViews()
    self.image = image
  }  
  
  init(configuration: AKImageCropperConfiguration) {
    super.init(frame:CGRectZero)
    self.configuration = configuration
    
    initViews()
  }
  
  private func initViews() {
    
    // Aspect View
    addSubview(aspectView)
    
    // Scroll View
    aspectView.addSubview(scrollView)
    
    // Image View
    scrollView.addSubview(imageView)
    
    // Overlay View
    aspectView.addSubview(overlayView)
    
    // Touch View
    aspectView.addSubview(touchView)
   
    touchView.receiver = scrollView
    scrollView.sender = touchView
  }
  
  //  MARK: - Layout
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    guard let image = image else { return }
    
    let sizeWithOffset = AKImageCropperUtility.increase(frame.size, byDx: -scrollViewOffset*2, dy: -scrollViewOffset*2)
    
    var scaleWithOffset = AKImageCropperUtility.getFitScaleMultiplier(image.size, relativeToSize: sizeWithOffset)
    scaleWithOffset = scaleWithOffset < 1 ? scaleWithOffset : 1
    
    let sizeWithOffsetScale = AKImageCropperUtility.increase(image.size, byMultiplier: scaleWithOffset)
    let сropRectWithScale = AKImageCropperUtility.increaseRect(cropRect, byMultiplier: scaleWithOffset / scrollView.zoomScale)
    
    // Aspect View
    aspectView.frame.size = AKImageCropperUtility.increase(sizeWithOffsetScale, byDx: scrollViewOffset*2, dy: scrollViewOffset*2)
    aspectView.frame = AKImageCropperUtility.centers(aspectView.frame, relativeToRect: frame)
    
    if сropRectWithScale != cropRect && cropRectSaved != nil {
      
      cropRectSaved = сropRectWithScale
      delegate?.cropRectChanged!(сropRectWithScale)
    }
    
    // Scroll View
    scrollView.frame = CGRect(origin: CGPointZero, size: aspectView.frame.size)
    scrollView.frame = scrollView.frame.insetBy(dx: scrollViewOffset, dy: scrollViewOffset)
    scrollView.zoomScale = scaleWithOffset
    
    // Overlay View
    overlayView.frame = CGRectInset(scrollView.frame, -cornerOffset, -cornerOffset)
    overlayView.setNeedsDisplay()
    
    // Touch View
    touchView.frame = CGRectInset(scrollView.frame, configuration.touchArea / -2, configuration.touchArea / -2)
    touchView.setNeedsDisplay()
  }
  
  //  MARK: - Life cycle
  
  deinit { print("deinit \(self.dynamicType)") }
  
  //  MARK: - Set crop rect
  
  /// Will set crop rectangle frame in the overlay view
  func cropRect(rect: CGRect) {
    
    guard overlayIsActive else { return }
    
    cropRectSaved = AKImageCropperUtility.rectFit(rect, toRect: CGRect(origin: CGPointZero, size: scrollView.frame.size), minSize: minimumSize)
    
    // Update views
    touchView.setNeedsDisplay()
    overlayView.setNeedsDisplay()
    
    delegate?.cropRectChanged!(rect)
  }
  
  /// Transion for all frames

  private func viewsScaleTransition(animated: Bool, completion:((Bool) -> Void)?) {
    
    var animated = animated
    
    // Animation not neede if scroll frame with offsets bigger that aspect frame
    animated = frame.size.width - scrollViewOffset > aspectView.frame.size.width || frame.size.height - scrollViewOffset > aspectView.frame.size.height
    
    if animated {
      UIView.animateWithDuration(configuration.overlay.animationDuration,
                                 delay: 0.0,
                                 options: configuration.overlay.animationOptions,
                                 animations: {
                                  self.layoutSubviews()
        },
                                 completion: { (complete) -> Void in
                                  if complete {
                                    completion?(true)
                                  }
                                  
        }
      )
    } else {
      layoutSubviews()
      completion?(true)
    }
  }
}

//  MARK: - UIScrollViewDelegate

extension AKImageCropperView: UIScrollViewDelegate {
  func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? { return imageView }
}

//  MARK: - AKImageCropperOverlayDelegate

extension AKImageCropperView: AKImageCropperTouchViewDelegate {
  func cropRectChanged(rect: CGRect) {
    cropRect(rect)
  }
}