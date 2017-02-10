//
//  ic_CGFloatExtension.swift
//  AKImageCropperView
//
//  Created by Artem Krachulov.
//  Copyright (c) 2016 Artem Krachulov. All rights reserved.
//

import UIKit

extension CGFloat {
    
    /** Rounds the value to the nearest with precision. */

    public func ic_roundTo(precision: Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(precision))
        return (self * divisor).rounded() / divisor
    }
}

/** Rounds the value to the nearest with multiplier. */

public func ic_round(x: CGFloat, multiplier: CGFloat) -> CGFloat {
    return multiplier * round(x / multiplier)
}
