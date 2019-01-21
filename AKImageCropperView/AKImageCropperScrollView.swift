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
    
    public var visibleRect: CGRect {
        return CGRect(
            x       : contentInset.left,
            y       : contentInset.top,
            width   : frame.size.width  - contentInset.left - contentInset.right,
            height  : frame.size.height - contentInset.top - contentInset.bottom)
    }
    
    /** Returns scaled visible rect of an UIScrollView's content  */
    
    public var scaledVisibleRect: CGRect {
        return CGRect(
            x       : (contentOffset.x + contentInset.left) / zoomScale,
            y       : (contentOffset.y + contentInset.top) / zoomScale,
            width   : visibleRect.size.width / zoomScale,
            height  : visibleRect.size.height / zoomScale)
    }
    
    // MARK: -
    // MARK: ** Initialization OBJECTS(VIEWS) & theirs parameters **
    
    fileprivate lazy var imageView: UIImageView! = {
        let view = UIImageView()
        return view
    }()
    
    public var image: UIImage! {
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
}
