//
//  AKImageCropperCropRectDelegate.swift
//  AKImageCropper
//  GitHub: https://github.com/artemkrachulov/AKImageCropper
//
//  Created by Artem Krachulov.
//  Copyright (c) 2016 Artem Krachulov. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//
//  This extension contains visual repreentation for 
//  crop rectanle such as stroke, grid and 4 corners.
//  You can override this protocol methods and draw own
//  circles, squares or other.
//
//  ver. 0.1
//

import UIKit

protocol AKImageCropperCropRectDelegate : class {
  func drawCornerInTopLeftPoint(point: CGPoint, configuration: AKImageCropperConfiguration)
  func drawCornerInTopRightPoint(point: CGPoint, configuration: AKImageCropperConfiguration)
  func drawCornerInBottomRightPoint(point: CGPoint, configuration: AKImageCropperConfiguration)
  func drawCornerInBottomLeftPoint(point: CGPoint, configuration: AKImageCropperConfiguration)
  func drawStroke(cropRect: CGRect, configuration: AKImageCropperConfiguration)
  func drawGrid(cropRect: CGRect, configuration: AKImageCropperConfiguration)
}

extension AKImageCropperCropRectDelegate {
  
  //  MARK:   Corners
  
  func drawCornerInTopLeftPoint(point: CGPoint, configuration: AKImageCropperConfiguration) {

    // Prepare Rects
    
    let rect = CGRect(origin: point, size: configuration.cropRect.cornerSize)
    let substractRect = CGRect(origin: CGPointMake(point.x + configuration.cropRect.cornerOffset, point.y + configuration.cropRect.cornerOffset), size: CGSizeMake(configuration.cropRect.cornerSize.width - configuration.cropRect.cornerOffset, configuration.cropRect.cornerSize.height - configuration.cropRect.cornerOffset))
    
    configuration.cropRect.cornerColor.setFill()
    
    let path = UIBezierPath(rect: rect)
    path.appendPath(UIBezierPath(rect: substractRect).bezierPathByReversingPath())
    path.fill()
  }
  
  func drawCornerInTopRightPoint(point: CGPoint, configuration: AKImageCropperConfiguration)  {
    
    // Prepare Rects
    
    let rect = CGRect(origin: point, size: configuration.cropRect.cornerSize)
    let substractRect = CGRect(origin: CGPointMake(point.x, point.y + configuration.cropRect.cornerOffset), size: CGSizeMake(configuration.cropRect.cornerSize.width - configuration.cropRect.cornerOffset, configuration.cropRect.cornerSize.height - configuration.cropRect.cornerOffset))
    
    configuration.cropRect.cornerColor.setFill()
    
    let path = UIBezierPath(rect: rect)
    path.appendPath(UIBezierPath(rect: substractRect).bezierPathByReversingPath())
    path.fill()
  }
  
  func drawCornerInBottomRightPoint(point: CGPoint, configuration: AKImageCropperConfiguration)  {
    
    // Prepare Rects

    let rect = CGRect(origin: point, size: configuration.cropRect.cornerSize)
    let substractRect = CGRect(origin: CGPointMake(point.x, point.y), size: CGSizeMake(configuration.cropRect.cornerSize.width - configuration.cropRect.cornerOffset, configuration.cropRect.cornerSize.height - configuration.cropRect.cornerOffset))
    
    configuration.cropRect.cornerColor.setFill()
    
    let path = UIBezierPath(rect: rect)
    path.appendPath(UIBezierPath(rect: substractRect).bezierPathByReversingPath())
    path.fill()
  }
  
  func drawCornerInBottomLeftPoint(point: CGPoint, configuration: AKImageCropperConfiguration) {
    
    // Prepare Rects

    let rect = CGRect(origin: point, size: configuration.cropRect.cornerSize)
    let substractRect = CGRect(origin: CGPointMake(point.x + configuration.cropRect.cornerOffset, point.y), size: CGSizeMake(configuration.cropRect.cornerSize.width - configuration.cropRect.cornerOffset, configuration.cropRect.cornerSize.height - configuration.cropRect.cornerOffset))

    configuration.cropRect.cornerColor.setFill()

    let path = UIBezierPath(rect: rect)
    path.appendPath(UIBezierPath(rect: substractRect).bezierPathByReversingPath())
    path.fill()
  }
  
  //  MARK:   Stroke
  
  func drawStroke(cropRect: CGRect, configuration: AKImageCropperConfiguration) {
    
    configuration.cropRect.cornerColor.set()
    
    let path = UIBezierPath(rect: cropRect)
    path.lineWidth = 1
    path.stroke()
  }
  
  //  MARK:   Grid
  
  func drawGrid(cropRect: CGRect, configuration: AKImageCropperConfiguration) {

    configuration.cropRect.gridColor.set()
    
    let path = UIBezierPath()
    path.lineWidth = 1

    for i in 0...configuration.cropRect.gridLinesCont {
      
      let startX = CGPointMake(CGRectGetMinX(cropRect) + CGRectGetWidth(cropRect) / (CGFloat(configuration.cropRect.gridLinesCont) + 1) * CGFloat(i), CGRectGetMinY(cropRect))
      let startY = CGPointMake(CGRectGetMinX(cropRect), CGRectGetMinY(cropRect) + CGRectGetHeight(cropRect) / (CGFloat(configuration.cropRect.gridLinesCont) + 1) * CGFloat(i))
      
      path.moveToPoint(startX)
      path.addLineToPoint(CGPointMake(startX.x, CGRectGetMaxY(cropRect)))
      
      path.moveToPoint(startY)
      path.addLineToPoint(CGPointMake(CGRectGetMaxX(cropRect), startY.y))
    }
    
    path.stroke()
  }
}
