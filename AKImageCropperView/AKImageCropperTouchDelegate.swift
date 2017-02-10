//
//  AKImageCropperTouchDelegate.swift
//  AKImageCropperView
//
//  Created by Artem Krachulov on 1/19/17.
//  Copyright © 2017 Artem Krachulov. All rights reserved.
//

import Foundation

protocol AKImageCropperTouchDelegate : class {
    
    func viewDidTouch(_ view: UIView, _ touches: Set<UITouch>, with event: UIEvent?)
    
    func viewDidMoveTouch(_ view: UIView, _ touches: Set<UITouch>, with event: UIEvent?)
    
    func viewDidEndTouch(_ view: UIView, _ touches: Set<UITouch>, with event: UIEvent?)
}
