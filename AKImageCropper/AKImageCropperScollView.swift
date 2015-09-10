//
//  AKImageCropperScollView.swift
//  GitHub: https://github.com/artemkrachulov/AKImageCropper
//
//  Created by Krachulov Artem
//  Copyright (c) 2015 Krachulov Artem. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//

import UIKit

class AKImageCropperScollView: UIScrollView {
    
    // MARK: - Properties
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    // Block / UnBlock scroll content
    weak var sender: AKImageCropperTouchView!
    
    // MARK: - Gestures
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return sender.flagScrollViewGesture
    }
}
