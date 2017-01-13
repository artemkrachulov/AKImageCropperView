//
//  AKImageCropperScrollView.swift
//  AKImageCropperView
//
//  Created by Artem Krachulov on 12/17/16.
//  Copyright © 2016 Artem Krachulov. All rights reserved.
//

import UIKit


class AKImageCropperScrollView: UIScrollView {

    /// Parent (main) class to translate some properties and objects.
    weak var cropperView: AKImageCropperView!
    
    open var image: UIImage? {
        didSet {
            
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
    
    
    }
    
    /// Scroll view saved parameters
    
    private struct ScrollViewSaved {
        var scaleAspectRatio: CGFloat
        var contentOffset: CGPoint
        var cropRectSize: CGSize
    }
    
    
    /// Saved parameters before complex layout animation
    
    private var scrollViewSaved = ScrollViewSaved(
        scaleAspectRatio    : 1.0,
        contentOffset       : .zero,
        cropRectSize        : .zero)
    
    /// Reversed frame value have fixed frame sizes direct to currect device orientation or by rotation angle.
    
    
    
    //  MARK: - Initialization
    
    /**
     
     Returns an overlay view initialized with the specified configuraiton.
     
     - parameter configuraiton: Configuration structure for the Overlay View appearance and behavior.
     
     */
    
    init() {
        super.init(frame: CGRect.zero)
        
       //        delegate = self
        alwaysBounceVertical = true
        alwaysBounceHorizontal = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
