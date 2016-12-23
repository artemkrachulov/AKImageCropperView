//
//  AKImageCropperOverlayViewConfigurationOverlay.swift
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

/// Overlay configuration struct.
public struct AKImageCropperOverlayViewConfigurationOverlay {
    
    /// The view’s background color.
    public var backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.5)
    
    /// A Boolean value that determines whether the blur effect is enable.
    ///
    /// The blur effect added over overlay view. The effect will disappear before user interaction will start. After manipulations, the effect will revert to the initial state.
    public var isBlurEnabled: Bool = true
    
    /// The intensity of the blur effect.
    public var blurStyle: UIBlurEffectStyle = .dark
    
    /// The blur effect alpha value.
    public var blurAlpha: CGFloat = 1.0
}
