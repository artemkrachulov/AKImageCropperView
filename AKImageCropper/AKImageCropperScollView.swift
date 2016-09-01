//
//  AKImageCropperScollView.swift
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

/// This scroll view subclass receive all geustures from touch view frame.
class AKImageCropperScollView: UIScrollView {
  
  //  MARK: - Properties
  
  /// Used for block or unblock scroll content
  weak var sender: AKImageCropperTouchView!
  
  //  MARK: - Gestures
  
  override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    return sender.flagScrollViewGesture
  }
}