//
//  CGFloat.swift
//  Extension file
//
//  Created by Krachulov Artem
//  Copyright (c) 2015 The Krachulovs. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//

import UIKit

/// Round a value with multiplier in the smaller side.
///
/// Usage:
///
///  ceil(1, 0.3) // 0.9
///  ceil(-0.75, 0.5) // -0.5

public func ceil(x: CGFloat, multiplier: CGFloat) -> CGFloat {

    // I some cases % not work properly
    let y = x / multiplier
    let floorY = floor(y)

    if y - floorY > 0 {

        return x < 0 ? (multiplier * floorY + multiplier) : multiplier * floorY
    } else {

        return x
    }
}
