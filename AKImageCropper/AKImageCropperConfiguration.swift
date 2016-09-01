//
//  AKImageCropperConfiguration.swift
//  AKImageCropper
//  GitHub: https://github.com/artemkrachulov/AKImageCropper
//
//  Created by Artem Krachulov.
//  Copyright (c) 2016 Artem Krachulov. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//
//  ver. 0.1
//

import UIKit

struct AKImageCropperConfiguration {
  
  /// Finger touch area on the stroke line of crop rectangle.
  ///
  /// Calculates:
  ///
  ///     offset(touchArea/2)-(stroke line)-inset(touchArea/2)
  ///
  ///               - - - Crop rectangle frame - - -
  ///              |
  ///              | < - Stroke line
  ///              |
  ///     |< - - - - - - - >| < - Finger touch area
  ///     | offset | inset  |
  ///
  /// The initial value of this property is `30` pixels.
  var touchArea: CGFloat = 30.0

  /// Crop rectangle configuration
  var cropRect = AKImageCropperCropRectConfiguration()
  
  /// Overlay View rectangle configuration
  var overlay = AKImageCropperOverlayViewConfiguration()
}