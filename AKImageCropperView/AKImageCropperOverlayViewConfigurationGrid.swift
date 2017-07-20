//
//  AKImageCropperCropViewConfigurationGrid.swift
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

/// Grid visual configuration struct.
public struct AKImageCropperCropViewConfigurationGrid {
    
    /// A Boolean value that determines whether the edge view is hidden.
    public var isHidden: Bool = false
    
    /// Hide grid after user interaction.
    public var alwaysShowGrid: Bool = false
    
    /**
     The number of vertical and horizontal lines inside the crop rectangle.
     
     -  vertical: Vertical lines count.
     -  horizontal: Horizontal lines count.
     */
    public var linesCount: (vertical: Int, horizontal: Int) = (vertical: 2, horizontal: 2)
    
    /// Vertical and horizontal lines width.
    public var linesWidth: CGFloat = 1.0
    
    /// Vertical and horizontal lines color.
    public var linesColor: UIColor = UIColor.white.withAlphaComponent(0.5)
}
