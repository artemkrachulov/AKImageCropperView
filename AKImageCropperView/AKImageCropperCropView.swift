//
//  AKImageCropperCropView.swift
//
//  Created by Artem Krachulov.
//  Copyright (c) 2016 Artem Krachulov. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software
// and associated documentation files (the "Software"), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute,
// sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
// PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
// FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//

import UIKit

//  MARK: - AKImageCropperCropViewDelegate

protocol AKImageCropperCropViewDelegate : class {
    
    func cropViewDidTouchCropRect(_ cropView: AKImageCropperCropView,  _ rect: CGRect)
    
    func cropViewDidChangeCropRect(_ cropView: AKImageCropperCropView,  _ rect: CGRect)
    
    func cropViewDidEndTouchCropRect(_ cropView: AKImageCropperCropView,  _ rect: CGRect)
}

//  MARK: - AKImageCropperCropView

/**
 
 Overlay view represented as AKImageCropperCropView open class. 
 
 Base configuration and behavior can be set or changed with **AKImageCropperOverlayConfiguration** structure. For deep visual changes create the children class and make the necessary configuration in the overrided methods.
 
 */
open class AKImageCropperCropView: UIView {
    
    fileprivate (set) lazy var overlayView: UIView! = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.clipsToBounds = true
//        view.isHidden = true
        return view
    }()
    
    open lazy var foregroundContainerImageView: UIView! = {
        let view = UIView()
        view.backgroundColor = UIColor.brown
        view.clipsToBounds = true
        view.isUserInteractionEnabled = false
        view.isHidden = true
        return view
    }()
    
    open lazy var foregroundImageView: UIImageView! = {
        let view = UIImageView()
        view.alpha = 0.5
        return view
    }()
    
    /// Configuration structure for the Overlay View appearance and behavior.
    open var configuraiton = AKImageCropperCropViewConfiguration()

    /// Parent (main) class to translate some properties and objects.    
    weak var cropperView: AKImageCropperView!

    //  MARK: Crop rectangle
    
    open var cropRect: CGRect! {
        return cropperView.cropRect
    }
    
    fileprivate var cropRectMoving: CGRect!
    
    /// Saved crop rectangle state
    fileprivate var cropRectBeforeMoving: CGRect!
    
    /// Saved first touch
    fileprivate var touchBeforeMoving: CGPoint!
    
    /// Current active crop area part
    fileprivate var activeCropAreaPart: AKCropAreaPart = .None {
        didSet { layoutSubviews() }
    }
    
    fileprivate struct AKCropAreaPart: OptionSet {
        
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        static let None                 = AKCropAreaPart(rawValue: 0)
        static let All                  = AKCropAreaPart(rawValue: 1)
        static let TopEdge              = AKCropAreaPart(rawValue: 2)
        static let LeftEdge             = AKCropAreaPart(rawValue: 3)
        static let BottomEdge           = AKCropAreaPart(rawValue: 4)
        static let RightEdge            = AKCropAreaPart(rawValue: 5)
        static let TopLeftCorner        = AKCropAreaPart(rawValue: 6)
        static let TopRightCorner       = AKCropAreaPart(rawValue: 7)
        static let BottomRightCorner    = AKCropAreaPart(rawValue: 8)
        static let BottomLeftCorner     = AKCropAreaPart(rawValue: 9)
        
        /// Active parts in moving
        
        func move() -> [AKCropAreaPart] {
            switch self {
            case AKCropAreaPart.TopEdge:
                return [AKCropAreaPart.TopEdge]
            case AKCropAreaPart.LeftEdge:
                return [AKCropAreaPart.LeftEdge]
            case AKCropAreaPart.BottomEdge:
                return [AKCropAreaPart.BottomEdge]
            case AKCropAreaPart.RightEdge:
                return [AKCropAreaPart.RightEdge]
            case AKCropAreaPart.TopLeftCorner:
                return [AKCropAreaPart.TopEdge, AKCropAreaPart.LeftEdge]
            case AKCropAreaPart.TopRightCorner:
                return [AKCropAreaPart.TopEdge, AKCropAreaPart.RightEdge]
            case AKCropAreaPart.BottomRightCorner:
                return [AKCropAreaPart.BottomEdge, AKCropAreaPart.RightEdge]
            case AKCropAreaPart.BottomLeftCorner:
                return [AKCropAreaPart.BottomEdge, AKCropAreaPart.LeftEdge]
            case AKCropAreaPart.All:
                return [AKCropAreaPart.TopEdge, AKCropAreaPart.RightEdge, AKCropAreaPart.BottomEdge, AKCropAreaPart.LeftEdge]
            default:
                return []
            }
        }
    }
    
    //  MARK: Managing the Delegate
    
    weak var delegate: AKImageCropperCropViewDelegate?
    
    //  MARK: Touch & Parts views
    
    fileprivate var topcropView: UIView!
    fileprivate var rightcropView: UIView!
    fileprivate var bottomcropView: UIView!
    fileprivate var leftcropView: UIView!
    fileprivate var topEdgeTouchView: UIView!
    fileprivate var topEdgeView: UIView!
    fileprivate var rightEdgeTouchView: UIView!
    fileprivate var rightEdgeView: UIView!
    fileprivate var bottomEdgeTouchView: UIView!
    fileprivate var bottomEdgeView: UIView!
    fileprivate var leftEdgeTouchView: UIView!
    fileprivate var leftEdgeView: UIView!
    fileprivate var topLeftCornerTouchView: UIView!
    fileprivate var topLeftCornerView: UIView!
    fileprivate var topRightCornerTouchView: UIView!
    fileprivate var topRightCornerView: UIView!
    fileprivate var bottomRightCornerTouchView: UIView!
    fileprivate var bottomRightCornerView: UIView!
    fileprivate var bottomLeftCornerTouchView: UIView!
    fileprivate var bottomLeftCornerView: UIView!
    fileprivate var gridView: UIView!
    fileprivate var gridViewVerticalLines: [UIView]!
    fileprivate var gridViewHorizontalLines: [UIView]!

    //  MARK: - Initialization

    /**
     
     Returns an overlay view initialized with the specified configuraiton.
     
     - parameter configuraiton: Configuration structure for the Overlay View appearance and behavior.
     
     */
    
    init() {
        super.init(frame: CGRect.zero)
        
        backgroundColor = UIColor.clear
        alpha = 0
        
        initialize()
    }
    
    public init(configuraiton: AKImageCropperCropViewConfiguration? = nil) {
        super.init(frame: CGRect.zero)
        
        if configuraiton != nil {
            self.configuraiton = configuraiton!
        }
        
        backgroundColor = UIColor.clear
        alpha = 0
        
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //  MARK: - Life cycle
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        overlayView.frame = frame
        foregroundContainerImageView.frame = cropRect
        
        topEdgeTouchView.frame = cropAreaTopEdgeFrame
        layoutTopEdgeView(topEdgeView,
                          inTouchView: topEdgeTouchView,
                          forState: activeCropAreaPart == .TopEdge
                            ? .highlighted
                            : .normal)
        
        rightEdgeTouchView.frame = cropAreaRightEdgeFrame
        layoutRightEdgeView(rightEdgeView,
                            inTouchView: rightEdgeTouchView,
                            forState: activeCropAreaPart == .RightEdge
                                ? .highlighted
                                : .normal)
        
        bottomEdgeTouchView.frame = cropAreaBottomEdgeFrame
        layoutBottomEdgeView(bottomEdgeView,
                             inTouchView: bottomEdgeTouchView,
                             forState: activeCropAreaPart == .BottomEdge
                                ? .highlighted
                                : .normal)
        
        leftEdgeTouchView.frame = cropAreaLeftEdgeFrame
        layoutLeftEdgeView(leftEdgeView,
                           inTouchView: leftEdgeTouchView,
                           forState: activeCropAreaPart == .LeftEdge
                            ? .highlighted
                            : .normal)
        
        topLeftCornerTouchView.frame = cropAreaTopLeftCornerFrame
        layoutTopLeftCornerView(topLeftCornerView,
                                inTouchView: topLeftCornerTouchView,
                                forState: activeCropAreaPart == .TopLeftCorner
                                    ? .highlighted
                                    : .normal)
        
        topRightCornerTouchView.frame = cropAreaTopRightCornerFrame
        layoutTopRightCornerView(topRightCornerView,
                                 inTouchView: topRightCornerTouchView,
                                 forState: activeCropAreaPart == .TopRightCorner
                                    ? .highlighted
                                    : .normal)
        
        bottomRightCornerTouchView.frame = cropAreaBottomRightCornerFrame
        layoutBottomRightCornerView(bottomRightCornerView,
                                    inTouchView: bottomRightCornerTouchView,
                                    forState: activeCropAreaPart == .BottomRightCorner
                                        ? .highlighted
                                        : .normal)
        
        bottomLeftCornerTouchView.frame = cropAreaBottomLeftCornerFrame
        layoutBottomLeftCornerView(bottomLeftCornerView,
                                   inTouchView: bottomLeftCornerTouchView,
                                   forState: activeCropAreaPart == .BottomLeftCorner
                                    ? .highlighted
                                    : .normal)
        
        gridView.frame = cropRect
        layoutGridView(gridView, gridViewHorizontalLines: gridViewHorizontalLines, gridViewVerticalLines: gridViewVerticalLines)
    }
    
    //  MARK: Crop rectangle parts rects

    fileprivate var cropAreaTopLeftCornerFrame: CGRect {
        return CGRect(
            origin: CGPoint(
                x: cropRect.origin.x - configuraiton.cornerTouchSize.width / 2,
                y: cropRect.origin.y - configuraiton.cornerTouchSize.height / 2),
            size: configuraiton.cornerTouchSize)
    }
    
    fileprivate var cropAreaTopRightCornerFrame: CGRect {
        return CGRect(
            origin: CGPoint(
                x: cropRect.maxX - configuraiton.cornerTouchSize.width / 2,
                y: cropRect.minY - configuraiton.cornerTouchSize.height / 2),
            size: configuraiton.cornerTouchSize)
    }
    
    fileprivate var cropAreaBottomLeftCornerFrame: CGRect {
        return CGRect(
            origin: CGPoint(
                x: cropRect.origin.x - configuraiton.cornerTouchSize.width / 2,
                y: cropRect.maxY - configuraiton.cornerTouchSize.height / 2),
            size: configuraiton.cornerTouchSize)
    }
    
    fileprivate var cropAreaBottomRightCornerFrame: CGRect {
        return CGRect(
            origin: CGPoint(
                x: cropRect.maxX - configuraiton.cornerTouchSize.width / 2,
                y: cropRect.maxY - configuraiton.cornerTouchSize.height / 2),
            size: configuraiton.cornerTouchSize)
    }
    
    fileprivate var cropAreaTopEdgeFrame: CGRect{
        return CGRect(
            x       : cropAreaTopLeftCornerFrame.maxX,
            y       : cropRect.origin.y - configuraiton.edgeTouchThickness.horizontal / 2,
            width   : cropRect.size.width - (cropAreaTopLeftCornerFrame.size.width / 2 + cropAreaTopRightCornerFrame.size.width / 2),
            height  : configuraiton.edgeTouchThickness.horizontal)
    }
    
    fileprivate var cropAreaBottomEdgeFrame: CGRect {
        return CGRect(
            x       : cropAreaBottomLeftCornerFrame.maxX,
            y       : cropRect.maxY - configuraiton.edgeTouchThickness.horizontal / 2,
            width   : cropRect.size.width - (cropAreaBottomLeftCornerFrame.size.width / 2 + cropAreaBottomRightCornerFrame.size.width / 2),
            height  : configuraiton.edgeTouchThickness.horizontal)
    }
    
    fileprivate var cropAreaRightEdgeFrame: CGRect {
        return CGRect(
            x       : cropRect.maxX - configuraiton.edgeTouchThickness.vertical / 2,
            y       : cropAreaTopLeftCornerFrame.maxY,
            width   : configuraiton.edgeTouchThickness.vertical,
            height  : cropRect.size.height - (cropAreaTopRightCornerFrame.size.height / 2 + cropAreaBottomRightCornerFrame.size.height / 2))
    }
    
    fileprivate var cropAreaLeftEdgeFrame: CGRect {
        return CGRect(
            x       : cropRect.origin.x - configuraiton.edgeTouchThickness.vertical / 2,
            y       : cropAreaTopLeftCornerFrame.maxY,
            width   : configuraiton.edgeTouchThickness.vertical,
            height  : cropRect.size.height - (cropAreaTopLeftCornerFrame.size.height / 2 + cropAreaBottomLeftCornerFrame.size.height / 2))
    }
    
    fileprivate func getCropAreaPartContainsPoint(_ point: CGPoint) -> AKCropAreaPart {
        if cropAreaTopEdgeFrame.contains(point) {
            return .TopEdge
        } else if cropAreaBottomEdgeFrame.contains(point) {
            return .BottomEdge
        } else if cropAreaRightEdgeFrame.contains(point) {
            return .RightEdge
        } else if cropAreaLeftEdgeFrame.contains(point) {
            return .LeftEdge
        } else if cropAreaTopLeftCornerFrame.contains(point) {
            return .TopLeftCorner
        } else if cropAreaTopRightCornerFrame.contains(point) {
            return .TopRightCorner
        } else if cropAreaBottomLeftCornerFrame.contains(point) {
            return .BottomLeftCorner
        } else if cropAreaBottomRightCornerFrame.contains(point) {
            return .BottomRightCorner
        } else {
            return .None
        }
    }
    
    // MARK: Other methods
    final func blurVisibility(visible: Bool, completion: ((Bool) -> Void)? = nil) {

        UIView.animate(withDuration: configuraiton.animation.duration, delay: 0, options: configuraiton.animation.options, animations: {
           
                self.overlayView.subviews.first?.alpha = visible ? self.configuraiton.overlay.blurAlpha : 0.0

        }, completion: { isComplete in
            completion?(isComplete)
        })
    }
    
    final func gridVisibility(visible: Bool, completion: ((Bool) -> Void)? = nil) {
        
        if configuraiton.grid.alwaysShowGrid {
             completion?(true)
            return
        }
        
        let animations: () -> Void = { _ in
            self.gridView.alpha = visible ? 1 : 0
        }
        
        if configuraiton.animation.duration == 0 {
            
            animations()
            
        } else {
        
            UIView.animate(withDuration: configuraiton.animation.duration, delay: 0, options: configuraiton.animation.options, animations: animations, completion: { isComplete in
                completion?(isComplete)
            })
        }
    }
    
    // MARK: - Draving Crop rect frame
    
    fileprivate func initialize() {
        
        /**
         
         2. Overlay view ‹‹ Image view
         
         */
        
        addSubview(overlayView)
        
        let blurEffect = UIBlurEffect(style: configuraiton.overlay.blurStyle)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = overlayView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlayView.addSubview(blurEffectView)
        
        /**
         
         3. Foreground container view ‹‹ (copy) Image view
         
         */
        
        foregroundContainerImageView.addSubview(foregroundImageView)
        addSubview(foregroundContainerImageView)
        
        
        
        //  Edges
        
        topEdgeTouchView = UIView()
//        topEdgeTouchView.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        addSubview(topEdgeTouchView)
        
        topEdgeView = UIView()
        topEdgeTouchView.addSubview(topEdgeView)
        
        rightEdgeTouchView = UIView()
//        rightEdgeTouchView.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        addSubview(rightEdgeTouchView)
        
        rightEdgeView = UIView()
        rightEdgeTouchView.addSubview(rightEdgeView)
        
        bottomEdgeTouchView = UIView()
//        bottomEdgeTouchView.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        addSubview(bottomEdgeTouchView)
        
        bottomEdgeView = UIView()
        bottomEdgeTouchView.addSubview(bottomEdgeView)
        
        leftEdgeTouchView = UIView()
//        leftEdgeTouchView.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        addSubview(leftEdgeTouchView)
        
        leftEdgeView = UIView()
        leftEdgeTouchView.addSubview(leftEdgeView)
        
        if configuraiton.edge.isHidden {
            topEdgeView.isHidden = true
            rightEdgeView.isHidden = true
            bottomEdgeView.isHidden = true
            leftEdgeView.isHidden = true
        }
        
        //  Corners
        
        topLeftCornerTouchView  = UIView()
//        topLeftCornerTouchView.backgroundColor = UIColor.green.withAlphaComponent(0.5)
        addSubview(topLeftCornerTouchView)
        
        topLeftCornerView = UIView()
        topLeftCornerView.layer.addSublayer(CAShapeLayer())
        topLeftCornerTouchView.addSubview(topLeftCornerView)
        
        topRightCornerTouchView  = UIView()
//        topRightCornerTouchView.backgroundColor = UIColor.green.withAlphaComponent(0.5)
        addSubview(topRightCornerTouchView)
        
        topRightCornerView = UIView()
        topRightCornerView.layer.addSublayer(CAShapeLayer())
        topRightCornerTouchView.addSubview(topRightCornerView)
        
        bottomRightCornerTouchView  = UIView()
//        bottomRightCornerTouchView.backgroundColor = UIColor.green.withAlphaComponent(0.5)
        addSubview(bottomRightCornerTouchView)
        
        bottomRightCornerView = UIView()
        bottomRightCornerView.layer.addSublayer(CAShapeLayer())
        bottomRightCornerTouchView.addSubview(bottomRightCornerView)
        
        bottomLeftCornerTouchView  = UIView()
//        bottomLeftCornerTouchView.backgroundColor = UIColor.green.withAlphaComponent(0.5)
        addSubview(bottomLeftCornerTouchView)
        
        bottomLeftCornerView = UIView()
        bottomLeftCornerView.layer.addSublayer(CAShapeLayer())
        bottomLeftCornerTouchView.addSubview(bottomLeftCornerView)
        
        if configuraiton.corner.isHidden {
            topLeftCornerView.isHidden = true
            topRightCornerView.isHidden = true
            bottomRightCornerView.isHidden = true
            bottomLeftCornerView.isHidden = true
        }
        
        //  Grid
        gridView = UIView()
        
        gridViewVerticalLines = []
        gridViewHorizontalLines = []
        
        for _ in 0..<configuraiton.grid.linesCount.vertical {
            
            let view = UIView()
            
            view.frame.size.width = configuraiton.grid.linesWidth
            view.backgroundColor = configuraiton.grid.linesColor
            
            gridViewVerticalLines.append(view)
            gridView.addSubview(view)
        }
        
        for _ in 0..<configuraiton.grid.linesCount.horizontal {
            
            let view = UIView()
            
            view.frame.size.height = configuraiton.grid.linesWidth
            view.backgroundColor = configuraiton.grid.linesColor
            
            gridViewHorizontalLines.append(view)
            gridView.addSubview(view)
        }
        addSubview(gridView)
        
        gridView.isHidden = configuraiton.grid.isHidden
        
        
        if configuraiton.grid.alwaysShowGrid {
            gridView.alpha = 1
        } else {
            gridView.alpha = 0
        }
    }
    
    /**
     
     Visual representation for top edge view in current user interaction state.
     
     -  parameter view: Top edge view.
     -  parameter touchView: Touch area view where added top edge view.
     -  parameter state: User interaction state.
     
     */
    open func layoutTopEdgeView(_ view: UIView, inTouchView touchView: UIView, forState state: AKImageCropperCropViewTouchState) {
        
        var color: UIColor
        var width: CGFloat
        
        if state == .normal {
            color = configuraiton.edge.normalLineColor
            width = configuraiton.edge.normalLineWidth
        } else {
            color = configuraiton.edge.highlightedLineColor
            width = configuraiton.edge.highlightedLineWidth
        }
        
        view.backgroundColor = color
        view.frame = CGRect(
            x       : touchView.bounds.origin.x - configuraiton.cornerTouchSize.width / 2 - configuraiton.edge.normalLineWidth,
            y       : touchView.bounds.midY - width,
            width   : touchView.bounds.size.width + configuraiton.cornerTouchSize.width + configuraiton.edge.normalLineWidth * 2,
            height  : width)
    }
    
    /**
     
     Visual representation for right edge view in current user interaction state.
     
     -  parameter view: Right edge view.
     -  parameter touchView: Touch area view where added right edge view.
     -  parameter state: User interaction state.
     
     */
    open func layoutRightEdgeView(_ view: UIView, inTouchView touchView: UIView, forState state: AKImageCropperCropViewTouchState) {
        
        var color: UIColor
        var width: CGFloat
        
        if state == .normal {
            color = configuraiton.edge.normalLineColor
            width = configuraiton.edge.normalLineWidth
        } else {
            color = configuraiton.edge.highlightedLineColor
            width = configuraiton.edge.highlightedLineWidth
        }
        
        view.backgroundColor = color
        view.frame = CGRect(
            x       : touchView.bounds.midX,
            y       : touchView.bounds.origin.y - configuraiton.cornerTouchSize.height / 2 - configuraiton.edge.normalLineWidth,
            width   : width,
            height  : touchView.bounds.size.height + configuraiton.cornerTouchSize.height + configuraiton.edge.normalLineWidth * 2)
    }
    
    /**
     
     Visual representation for bottom edge view in current user interaction state.
     
     -  parameter view: Bottom edge view.
     -  parameter touchView: Touch area view where added bottom edge view.
     -  parameter state: User interaction state.
     
     */
    open func layoutBottomEdgeView(_ view: UIView, inTouchView touchView: UIView, forState state: AKImageCropperCropViewTouchState) {
        
        var color: UIColor
        var width: CGFloat
        
        if state == .normal {
            color = configuraiton.edge.normalLineColor
            width = configuraiton.edge.normalLineWidth
        } else {
            color = configuraiton.edge.highlightedLineColor
            width = configuraiton.edge.highlightedLineWidth
        }
      
        view.backgroundColor = color
        view.frame = CGRect(
            x       : touchView.bounds.origin.x - configuraiton.cornerTouchSize.width / 2 - configuraiton.edge.normalLineWidth,
            y       : touchView.bounds.midY,
            width   : touchView.bounds.size.width + configuraiton.cornerTouchSize.width + configuraiton.edge.normalLineWidth * 2,
            height  : width)
    }
    
    /**
     
     Visual representation for left edge view in current user interaction state.
     
     -  parameter view: Left edge view.
     -  parameter touchView: Touch area view where added left edge view.
     -  parameter state: User interaction state.
     
     */
    open func layoutLeftEdgeView(_ view: UIView, inTouchView touchView: UIView, forState state: AKImageCropperCropViewTouchState) {
        
        var color: UIColor
        var width: CGFloat
        
        if state == .normal {
            color = configuraiton.edge.normalLineColor
            width = configuraiton.edge.normalLineWidth
        } else {
            color = configuraiton.edge.highlightedLineColor
            width = configuraiton.edge.highlightedLineWidth
        }
        
        view.backgroundColor = color
        view.frame = CGRect(
            x       : touchView.bounds.midX - width,
            y       : touchView.bounds.origin.y - configuraiton.cornerTouchSize.height / 2 - configuraiton.edge.normalLineWidth,
            width   : width,
            height  : touchView.bounds.size.height + configuraiton.cornerTouchSize.height + configuraiton.edge.normalLineWidth * 2)
    }
    
    /**
     
     Visual representation for top left corner view in current user interaction state. Drawing going with added shape layer.
     
     -  parameter view: Top left corner view.
     -  parameter touchView: Touch area view where added top left edge view.
     -  parameter state: User interaction state.
     
     */
    open func layoutTopLeftCornerView(_ view: UIView, inTouchView touchView: UIView, forState state: AKImageCropperCropViewTouchState) {
        
        var lineWidth: CGFloat
        let layer: CAShapeLayer = view.layer.sublayers!.first as! CAShapeLayer
        
        if state == .normal {
            
            layer.fillColor = configuraiton.corner.normalLineColor.cgColor
            view.frame.size = configuraiton.corner.normaSize
            lineWidth = configuraiton.corner.normalLineWidth
            
        } else {
            
            layer.fillColor = configuraiton.edge.highlightedLineColor.cgColor
            view.frame.size = configuraiton.corner.highlightedSize
            lineWidth = configuraiton.corner.highlightedLineWidth
        }
        
        view.center = CGPoint(x: touchView.bounds.midX, y: touchView.bounds.midY)
        
        let rect = CGRect(origin: CGPoint(x: view.bounds.midX - lineWidth, y: view.bounds.midY - lineWidth), size: view.frame.size)
        
        let substractRect = CGRect(
            x       : rect.origin.x + lineWidth,
            y       : rect.origin.y + lineWidth,
            width   : rect.size.width - lineWidth,
            height  : rect.size.height - lineWidth)
        
        let path = UIBezierPath(rect: rect)
        path.append(UIBezierPath(rect: substractRect).reversing())
        
        layer.path = path.cgPath
    }
    
    /**
     
     Visual representation for top right corner view in current user interaction state. Drawing going with added shape layer.
     
     -  parameter view: Top right corner view.
     -  parameter touchView: Touch area view where added top right edge view.
     -  parameter state: User interaction state.
     
     */
    open func layoutTopRightCornerView(_ view: UIView, inTouchView touchView: UIView, forState state: AKImageCropperCropViewTouchState) {
        
        var lineWidth: CGFloat
        let layer: CAShapeLayer = view.layer.sublayers!.first as! CAShapeLayer
        
        if state == .normal {
            
            layer.fillColor = configuraiton.corner.normalLineColor.cgColor
            view.frame.size = configuraiton.corner.normaSize
            lineWidth = configuraiton.corner.normalLineWidth
            
        } else {
            
            layer.fillColor = configuraiton.edge.highlightedLineColor.cgColor
            view.frame.size = configuraiton.corner.highlightedSize
            lineWidth = configuraiton.corner.highlightedLineWidth
        }
        
        view.center = CGPoint(x: touchView.bounds.midX, y: touchView.bounds.midY)
        
        let rect = CGRect(origin: CGPoint(x: -view.bounds.midX + lineWidth, y: view.bounds.midY - lineWidth), size: view.frame.size)
        
        let substractRect = CGRect(
            x       : rect.origin.x,
            y       : rect.origin.y + lineWidth,
            width   : rect.size.width - lineWidth,
            height  : rect.size.height - lineWidth)
        
        let path = UIBezierPath(rect: rect)
        
        path.append(UIBezierPath(rect: substractRect).reversing())
        layer.path = path.cgPath
    }
    
    /**
     
     Visual representation for bottom right corner view in current user interaction state. Drawing going with added shape layer.
     
     -  parameter view: Bottom right corner view.
     -  parameter touchView: Touch area view where added bottom right edge view.
     -  parameter state: User interaction state.
     
     */
    open func layoutBottomRightCornerView(_ view: UIView, inTouchView touchView: UIView, forState state: AKImageCropperCropViewTouchState) {
        
        var lineWidth: CGFloat
        let layer: CAShapeLayer = view.layer.sublayers!.first as! CAShapeLayer
        
        if state == .normal {
            
            layer.fillColor = configuraiton.corner.normalLineColor.cgColor
            view.frame.size = configuraiton.corner.normaSize
            lineWidth = configuraiton.corner.normalLineWidth
            
        } else {
            
            layer.fillColor = configuraiton.edge.highlightedLineColor.cgColor
            view.frame.size = configuraiton.corner.highlightedSize
            lineWidth = configuraiton.corner.highlightedLineWidth
        }
        
        view.center = CGPoint(x: touchView.bounds.midX, y: touchView.bounds.midY)
        
        let rect = CGRect(origin: CGPoint(x: -view.bounds.midX + lineWidth, y: -view.bounds.midY + lineWidth), size: view.frame.size)
        
        let substractRect = CGRect(
            x       : rect.origin.x,
            y       : rect.origin.y,
            width   : rect.size.width - lineWidth,
            height  : rect.size.height - lineWidth)
        
        let path = UIBezierPath(rect: rect)
        
        path.append(UIBezierPath(rect: substractRect).reversing())
        layer.path = path.cgPath
    }
    
    /**
     
     Visual representation for bottom left corner view in current user interaction state. Drawing going with added shape layer.
     
     -  parameter view: Bottom left corner view.
     -  parameter touchView: Touch area view where added bottom left edge view.
     -  parameter state: User interaction state.
     
     */
    open func layoutBottomLeftCornerView(_ view: UIView, inTouchView touchView: UIView, forState state: AKImageCropperCropViewTouchState) {
        
        var lineWidth: CGFloat
        let layer: CAShapeLayer = view.layer.sublayers!.first as! CAShapeLayer
        
        if state == .normal {
            
            layer.fillColor = configuraiton.corner.normalLineColor.cgColor
            view.frame.size = configuraiton.corner.normaSize
            lineWidth = configuraiton.corner.normalLineWidth
            
        } else {
            
            layer.fillColor = configuraiton.edge.highlightedLineColor.cgColor
            view.frame.size = configuraiton.corner.highlightedSize
            lineWidth = configuraiton.corner.highlightedLineWidth
        }
        
        view.center = CGPoint(x: touchView.bounds.midX, y: touchView.bounds.midY)
        
        let rect = CGRect(origin: CGPoint(x: view.bounds.midX - lineWidth, y: -view.bounds.midY + lineWidth), size: view.frame.size)
        
        let substractRect = CGRect(
            x       : rect.origin.x + lineWidth,
            y       : rect.origin.y,
            width   : rect.size.width - lineWidth,
            height  : rect.size.height - lineWidth)
        
        let path = UIBezierPath(rect: rect)
        
        path.append(UIBezierPath(rect: substractRect).reversing())
        layer.path = path.cgPath
    }
    
    /**
     
     Visual representation for grid view.
     
     -  parameter view: Grid view.
     -  parameter gridViewHorizontalLines: Horizontal line view`s array.
     -  parameter gridViewVerticalLines: Vertical line view`s array.
     
     */
    open func layoutGridView(_ view: UIView, gridViewHorizontalLines: [UIView], gridViewVerticalLines: [UIView]) {
        
        for (i, line) in gridViewHorizontalLines.enumerated() {
            
            line.frame.origin = CGPoint(x: 0, y: view.frame.height * CGFloat(i + 1) / CGFloat(gridViewHorizontalLines.count + 1))
            line.frame.size.width = view.frame.width
        }
        
        for (i, line) in gridViewVerticalLines.enumerated() {
            
            line.frame.origin = CGPoint(x: view.frame.width * CGFloat(i + 1) / CGFloat(gridViewVerticalLines.count + 1), y: 0)
            line.frame.size.height = view.frame.height
        }
    }
    
    // MARK: Touches
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let firstTouch = touches.first else {
            return
        }
        
        //  Save

        cropRectBeforeMoving = cropRect
        cropRectMoving = cropRect
        
        touchBeforeMoving = firstTouch.location(in: self)

        // Crop Rect touched area
        activeCropAreaPart = getCropAreaPartContainsPoint(touchBeforeMoving)
        
        delegate?.cropViewDidTouchCropRect(self, cropRect)
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        let moveEdges = activeCropAreaPart.move()
        
        guard let touch = touches.first, !moveEdges.isEmpty else  {
            return
        }

        // GET TRANSLATION POINT
   
        let point = touch.location(in: self)
        let previousPoint = touch.previousLocation(in: self)
        
        let translationPoint = CGPoint(x: point.x - previousPoint.x, y: point.y - previousPoint.y)
        
        // MOVE FRAME

        if moveEdges.contains(.TopEdge) {
            
            cropRectMoving.origin.y += translationPoint.y
            cropRectMoving.size.height -= translationPoint.y
            
            let pointInEdge = touchBeforeMoving.y - cropRectBeforeMoving.minY
            let minStickPoint = pointInEdge + cropperView.cropRectMaxFrame.minY
            let maxStickPoint = pointInEdge + cropRectBeforeMoving.maxY - configuraiton.minCropRectSize.height
            
            if point.y > maxStickPoint || cropRectMoving.height < configuraiton.minCropRectSize.height {
                cropRectMoving.origin.y = cropRectBeforeMoving.maxY - configuraiton.minCropRectSize.height
                cropRectMoving.size.height = configuraiton.minCropRectSize.height
            }
            
            if point.y < minStickPoint {
                cropRectMoving.origin.y = cropperView.cropRectMaxFrame.minY
                cropRectMoving.size.height = cropRectBeforeMoving.maxY - cropperView.cropRectMaxFrame.minY
            }
        }
        
        if moveEdges.contains(.RightEdge) {
            
            cropRectMoving.size.width += translationPoint.x
            
            let pointInEdge = touchBeforeMoving.x - cropRectBeforeMoving.maxX
            let minStickPoint = pointInEdge + cropRectBeforeMoving.minX + configuraiton.minCropRectSize.width
            let maxStickPoint = pointInEdge + cropperView.cropRectMaxFrame.maxX
            
            if  point.x > maxStickPoint {
                cropRectMoving.size.width =  cropperView.cropRectMaxFrame.maxX - cropRectMoving.origin.x
            }
            
            if point.x < minStickPoint || cropRectMoving.width < configuraiton.minCropRectSize.width {
                cropRectMoving.size.width = configuraiton.minCropRectSize.width
            }
        }
        
        if moveEdges.contains(.BottomEdge) {

            cropRectMoving.size.height += translationPoint.y
            
            let pointInEdge = touchBeforeMoving.y - cropRectBeforeMoving.maxY
            let minStickPoint = pointInEdge + cropRectBeforeMoving.minY + configuraiton.minCropRectSize.height
            let maxStickPoint = pointInEdge + cropperView.cropRectMaxFrame.maxY
            
            if  point.y > maxStickPoint {
                cropRectMoving.size.height = cropperView.cropRectMaxFrame.maxY - cropRectMoving.origin.y
            }
            
            if point.y < minStickPoint || cropRectMoving.height < configuraiton.minCropRectSize.height {
                cropRectMoving.size.height = configuraiton.minCropRectSize.height
            }
        }
        
        if moveEdges.contains(.LeftEdge) {
            
            cropRectMoving.origin.x += translationPoint.x
            cropRectMoving.size.width -= translationPoint.x
            
            let pointInEdge = touchBeforeMoving.x - cropRectBeforeMoving.minX
            let minStickPoint = pointInEdge + cropperView.cropRectMaxFrame.minX
            let maxStickPoint = pointInEdge + cropRectBeforeMoving.maxX - configuraiton.minCropRectSize.width
            
            if  point.x > maxStickPoint || cropRectMoving.width < configuraiton.minCropRectSize.width {
                cropRectMoving.origin.x = cropRectBeforeMoving.maxX - configuraiton.minCropRectSize.width
                cropRectMoving.size.width = configuraiton.minCropRectSize.width
            }
            
            if point.x < minStickPoint {
                cropRectMoving.origin.x = cropperView.cropRectMaxFrame.minX
                cropRectMoving.size.width = cropRectBeforeMoving.maxX - cropperView.cropRectMaxFrame.minX
            }
        }
        
        // Send new crop rectangle frame to main class

        layoutSubviews()
        
        delegate?.cropViewDidChangeCropRect(self, cropRectMoving)
        
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        activeCropAreaPart = .None
        delegate?.cropViewDidEndTouchCropRect(self, cropRectMoving)
    }
    
    // MARK: - Instance Method to detect and translate point
    
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        print("ZZZ")
        print(event!.type.rawValue)
        debugPrint(event!.type)
        
        guard alpha == 1 else {
            return cropperView.scrollView
        }
        
        return self.point(inside: point, with: event) && getCropAreaPartContainsPoint(point) != .None
            ? self
            : cropperView.scrollView
    }
    
   
    open var image: UIImage? {
        didSet {
            foregroundImageView.image = image
        }
    }
    
    
    func matchForegroundToScrollView(scrollView: UIScrollView) {
    
        
        
        let p = scrollView.contentOffset
        
       
        
        let origin = CGPoint(
            x: -(p.x + foregroundContainerImageView.frame.origin.x),
            y: -(p.y + foregroundContainerImageView.frame.origin.y))
        
        foregroundImageView.frame.origin = origin
        foregroundImageView.frame.size = scrollView.contentSize
        
    }
    
    
    
}
