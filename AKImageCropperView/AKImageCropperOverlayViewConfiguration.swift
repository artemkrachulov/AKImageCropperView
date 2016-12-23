//
//  AKImageCropperOverlayViewConfiguration.swift
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

/// Overlay view configuration struct.
public struct AKImageCropperOverlayViewConfiguration {
    
    public init() {}
    
    //  MARK: Crop rectangle
    
    /// Delay before the crop rectangle will scale to fit cropper view frame edges.
    public var zoomingToFitDelay: TimeInterval = 2.0

    /**
     
     Animation options for layout transitions.
     
     -  duration: The duration of the transition animation, measured in seconds.     
     -  options: Specifies the supported animation curves.
     
     */
    public var animation: (duration: TimeInterval, options: UIViewAnimationOptions) = (duration: 0.3, options: .curveEaseInOut)

    /// Edges insets for crop rectangle. Static values on rotation.
    public var cropRectInsets = UIEdgeInsetsMake(50, 50, 50, 50)
    
    /// The smallest value for the crop rectangle sizes. Initial value of this property is 30 pixels width and 30 pixels height.
    public var minCropRectSize: CGSize = CGSize(width: 60, height: 60)
    
    /// Touch view where will be drawn the corner.
    public var cornerTouchSize: CGSize = CGSize(width: 30.0, height: 30.0)
    
    /**
     
     Thickness for edges touch area. This touch view is centered on the edge line.
     
     -  vertical: Thickness for vertical edges: Left, Right.
     -  horizontal: Thickness for horizontal edges: Top, Bottom.
     
     */
    public var edgeTouchThickness: (vertical: CGFloat, horizontal: CGFloat) = (vertical: 20.0, horizontal: 20.0)

    //  MARK: Visual Appearance
    
    /// Overlay visual configuration.
    public var overlay = AKImageCropperOverlayViewConfigurationOverlay()
    
    /// Edges visual configuration.
    public var edge = AKImageCropperOverlayViewConfigurationEdge()
    
    /// Corners visual configuration.
    public var corner = AKImageCropperOverlayViewConfigurationCorner()
    
    /// Grid visual configuration.    
    public var grid = AKImageCropperOverlayViewConfigurationGrid()
}
