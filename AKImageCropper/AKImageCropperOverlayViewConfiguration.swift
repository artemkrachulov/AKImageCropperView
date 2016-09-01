//
//  AKImageCropperOverlayViewConfiguration.swift
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

struct AKImageCropperOverlayViewConfiguration {
  
  ///  The duration of the transition animation, measured in seconds. The initial value of this property is `0.3` seconds.
  var animationDuration: NSTimeInterval = 0.3
  
  /// Specifies the supported animation curves. The initial value of this property is `CurveEaseOut`.
  var animationOptions: UIViewAnimationOptions = .CurveEaseOut
  
  /// The view’s background color. The initial value of this property is `UIColor.blackColor().colorWithAlphaComponent(0.5)`.
  var bgColor: UIColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
}
