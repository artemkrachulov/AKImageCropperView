//
//  CustomImageCropperOverlayView.swift
//  Demo
//
//  Created by Artem Krachulov on 11/28/16.
//  Copyright © 2016 Artem Krachulov. All rights reserved.
//

import Foundation
import AKImageCropperView

final class CustomImageCropperOverlayView: AKImageCropperOverlayView {
    
    private func drawCycleInCornerView(_ view: UIView, inTouchView touchView: UIView, forState state: AKImageCropperCropViewTouchState) {
        
        var color: UIColor
        var width: CGFloat
        
        if state == .normal {
            color = configuraiton.corner.normalLineColor
            width = configuraiton.corner.normalLineWidth
        } else {
            color = configuraiton.corner.highlightedLineColor
            width = configuraiton.corner.highlightedLineWidth
        }
        
        let layer: CAShapeLayer = view.layer.sublayers!.first as! CAShapeLayer
        
        let circlePath = UIBezierPath(
            arcCenter:  CGPoint(x: touchView.bounds.midX, y: touchView.bounds.midY),
            radius: width,
            startAngle: 0.0,
            endAngle: CGFloat(Double.pi * 2),
            clockwise: true)

        layer.path = circlePath.cgPath
        layer.fillColor = color.cgColor
        layer.strokeColor = color.cgColor
    }
    
    override func layoutTopLeftCornerView(_ view: UIView, inTouchView touchView: UIView, forState state: AKImageCropperCropViewTouchState) {
        drawCycleInCornerView(view, inTouchView: touchView, forState: state)
    }
    
    override func layoutTopRightCornerView(_ view: UIView, inTouchView touchView: UIView, forState state: AKImageCropperCropViewTouchState) {
        drawCycleInCornerView(view, inTouchView: touchView, forState: state)
    }
    override func layoutBottomLeftCornerView(_ view: UIView, inTouchView touchView: UIView, forState state: AKImageCropperCropViewTouchState) {
        drawCycleInCornerView(view, inTouchView: touchView, forState: state)
    }
    
    override func layoutBottomRightCornerView(_ view: UIView, inTouchView touchView: UIView, forState state: AKImageCropperCropViewTouchState) {
        drawCycleInCornerView(view, inTouchView: touchView, forState: state)
    }
}
