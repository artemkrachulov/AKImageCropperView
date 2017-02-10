//
//  AKImageCropperScrollView.swift
//  AKImageCropperView
//
//  Created by Artem Krachulov on 12/17/16.
//  Copyright © 2016 Artem Krachulov. All rights reserved.
//

import UIKit

final class AKImageCropperScrollView: UIScrollView {
    
    // MARK: -
    // MARK: ** Properties **
    
    /** Return visible rect of an UIScrollView's content */
    
    open var visibleRect: CGRect {
        return CGRect(
            x       : contentInset.left,
            y       : contentInset.top,
            width   : frame.size.width  - contentInset.left - contentInset.right,
            height  : frame.size.height - contentInset.top - contentInset.bottom)
    }
    
    /** Returns scaled visible rect of an UIScrollView's content  */
    
    open var scaledVisibleRect: CGRect {
        return CGRect(
            x       : contentOffset.x / zoomScale,
            y       : contentOffset.y / zoomScale,
            width   : frame.size.width / zoomScale,
            height  : frame.size.height / zoomScale)
    }
    
    //  MARK: Managing the Delegate
    
    /** All touches events */
    
    weak var touchDelegate: AKImageCropperTouchDelegate?
    
    // MARK: -
    // MARK: ** Initialization OBJECTS(VIEWS) & theirs parameters **
    
    fileprivate lazy var imageView: UIImageView! = {
        let view = UIImageView()
        return view
    }()
    
    open var image: UIImage! {
        didSet {
            
            /* Prepare scroll view to changing the image */
            
            maximumZoomScale = 1
            minimumZoomScale = 1
            zoomScale = 1
            
            /* Update an image view */
            
            imageView.image = image
            imageView.frame.size = image.size
            
            contentSize = image.size
        }
    }
    
    //  MARK: - Initialization
    
    /** Returns an scroll view initialized object. */
    
    init() {
        super.init(frame: .zero)
        
        alwaysBounceVertical = true
        alwaysBounceHorizontal = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        
        addSubview(imageView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Touches
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDelegate?.viewDidTouch(self, touches, with: event)
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDelegate?.viewDidMoveTouch(self, touches, with: event)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesEnded scroll")
        touchDelegate?.viewDidEndTouch(self, touches, with: event)
    }
}
