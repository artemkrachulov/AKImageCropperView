//
//  AKImageCropperScollView.swift
//  AKImageCropperDemo
//
//  Created by Krachulov Artem  on 9/7/15.
//  Copyright (c) 2015 Artem Krachulov. All rights reserved.
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
