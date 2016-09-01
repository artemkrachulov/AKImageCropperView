//
//  AKImageCropperCropRectConfiguration.swift
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

struct AKImageCropperCropRectConfiguration {
  
  /// The minimum crop rectangle frame size to which is possible reduce frame. Maximum value equal to the scroll view frame size. The initial value of this property is `30` pixels width and `30` pixels height.
  var minimumSize: CGSize = CGSizeMake(30, 30)
  
  /// True value will show grid inside crop rectange frame.
  var grid: Bool = true
  
  /// The number of vertical and horizontal lines inside the crop rectangle. The initial value of this property is `2` (`2` vertical and `2` horizontal lines).
  var gridLinesCont: Int = 2
  
  /// The width of the grig vertical and horizontal line. The initial value of this property is `1` px.
  var gridLineWidth: Int = 1
  
  /// The color of the vertical and horizontal lines inside the crop rectangle. The initial value of this property is `UIColor.whiteColor()`.
  var gridColor: UIColor = UIColor.whiteColor()
  
  /// The distance to which will be offset corners of the crop rectangle stroke line. The initial value of this property is `3` pixels.
  var cornerOffset: CGFloat = 3.0
  /// The size of the crop rectangle corner. The initial value of this property is `18` pixels width and `18` pixels height.
  var cornerSize: CGSize = CGSizeMake(18, 18)
  
  /// The color of the corners of the crop rectangle. The initial value of this property is `UIColor.whiteColor()`.
  var cornerColor: UIColor = UIColor.whiteColor()
  
  /// The color of the outer crop rectangle line. The initial value of this property is   `UIColor.whiteColor()`.
  var strokeColor: UIColor = UIColor.whiteColor()
  
  /// The width of the crop rectangle stroke. The initial value of this property is `1` px.
  var strokeWidth: Int = 1
}
