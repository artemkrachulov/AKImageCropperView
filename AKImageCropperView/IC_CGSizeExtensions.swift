//
//  IC_CGSizeExtensions.swift
//  AKImageCropperView
//
//  Created by Artem Krachulov.
//  Copyright (c) 2016 Artem Krachulov. All rights reserved.
//

import Foundation

/** Returns fill scale value relative to target size with aspect ratio. */

func ic_CGSizeFitScaleMultiplier(_ size1: CGSize, relativeToSize size2: CGSize) -> CGFloat {
    
    guard size1.width != 0 && size1.height != 0 else { return 1.0 }
    
    return min(size2.height / size1.height, size2.width / size1.width)
}

/** Returns fill scale value relative to target size with aspect ratio. */

func ic_CGSizeFillScaleMultiplier(_ size1: CGSize, relativeToSize size2: CGSize) -> CGFloat {
    
    guard size1.width != 0 && size1.height != 0 else { return 1.0 }
    
    return max(size2.height / size1.height, size2.width / size1.width)
}

/** Returns size that fits min and max sizes. */

func ic_CGSizeFits(_ size: CGSize, minSize: CGSize, maxSize: CGSize) -> CGSize {
    
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
