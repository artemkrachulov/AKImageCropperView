//
//  IC_CGPointExtension.swift
//  AKImageCropperView
//
//  Created by Artem Krachulov.
//  Copyright (c) 2016 Artem Krachulov. All rights reserved.
//

import Foundation

/** Return centered origin value relative to other size . */

func ic_CGPointCenters(_ size1: CGSize, relativeToSize size2: CGSize) -> CGPoint {
    return CGPoint(x: size2.width / 2 - size1.width / 2, y: size2.height / 2 - size1.height / 2)
}

