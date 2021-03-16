//
//  AKImageCropperOverlayView.swift
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

protocol AKImageCropperOverlayViewDelegate : AnyObject {
    func cropperOverlayViewDidChangeCropRect(_ view: AKImageCropperOverlayView, _ cropRect: CGRect)
}

open class AKImageCropperOverlayView: UIView {
    
    // MARK: -
    // MARK: ** Properties **

    /** Configuration structure for the Overlay View appearance and behavior. */

    open var configuraiton = AKImageCropperCropViewConfiguration()
    
    /** Crop rectangle */
    
    internal var cropRect: CGRect = .zero
    
    /** Saved crop rectangle state */
    
    fileprivate var touchesBegan: (touch: CGPoint, cropRect: CGRect)!

    /** Current active crop area part */
    
    fileprivate var activeCropAreaPart: AKCropAreaPart = .none {
        didSet { layoutSubviews() }
    }
    
    fileprivate struct AKCropAreaPart: OptionSet {
        
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        static let none                 = AKCropAreaPart(rawValue: 1 << 0)
        static let topEdge              = AKCropAreaPart(rawValue: 1 << 1)
        static let leftEdge             = AKCropAreaPart(rawValue: 1 << 2)
        static let bottomEdge           = AKCropAreaPart(rawValue: 1 << 3)
        static let rightEdge            = AKCropAreaPart(rawValue: 1 << 4)

        static let all: AKCropAreaPart = [.topEdge, .rightEdge, .bottomEdge, .leftEdge]
        
        static let topLeftCorner: AKCropAreaPart        = [.topEdge, .leftEdge]
        static let topRightCorner: AKCropAreaPart       = [.topEdge, .rightEdge]
        static let bottomRightCorner: AKCropAreaPart    = [.bottomEdge, .rightEdge]
        static let bottomLeftCorner: AKCropAreaPart     = [.bottomEdge, .leftEdge]
    }
    
    //  MARK: Managing the Delegate

    weak var delegate: AKImageCropperOverlayViewDelegate?
    
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
    
    // MARK: -
    // MARK: ** Initialization OBJECTS(VIEWS) & theirs parameters **
    
    /** Parent (main) class to translate some properties and objects. */
    
    weak var cropperView: AKImageCropperView!

    fileprivate (set) lazy var overlayView: UIView! = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.clipsToBounds = true
        return view
    }()
    
    fileprivate lazy var containerImageView: UIView! = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.clipsToBounds = true
        view.isUserInteractionEnabled = false
        return view
    }()
    
    fileprivate lazy var imageView: UIImageView! = {
        let view = UIImageView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    open var image: UIImage! {
        didSet {
            imageView.image = image
        }
    }
    
    //  MARK: - Initialization

    /**
     Returns an overlay view initialized with the specified configuraiton.
     
     - Parameter configuraiton: Configuration structure for the Overlay View appearance and behavior.
     */
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .clear
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
    
    // MARK: - Draving Crop rect frame
    
    fileprivate func initialize() {
        
        /*
         Create views layout.
         Step by step
         
         1. OverlayView
         */
        
        addSubview(overlayView)
        
        let blurEffect = UIBlurEffect(style: configuraiton.overlay.blurStyle)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = self.configuraiton.overlay.blurAlpha
        
        blurEffectView.frame = overlayView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlayView.addSubview(blurEffectView)
        
        /* 2. Container view ‹‹ Image view */
        
        containerImageView.addSubview(imageView)
        addSubview(containerImageView)
        
        /* 3. Crop rectangle */
        
        //  Edges
        
        topEdgeTouchView = UIView()
        addSubview(topEdgeTouchView)
        
        topEdgeView = UIView()
        topEdgeTouchView.addSubview(topEdgeView)
        
        rightEdgeTouchView = UIView()
        addSubview(rightEdgeTouchView)
        
        rightEdgeView = UIView()
        rightEdgeTouchView.addSubview(rightEdgeView)
        
        bottomEdgeTouchView = UIView()
        addSubview(bottomEdgeTouchView)
        
        bottomEdgeView = UIView()
        bottomEdgeTouchView.addSubview(bottomEdgeView)
        
        leftEdgeTouchView = UIView()
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
        addSubview(topLeftCornerTouchView)
        
        topLeftCornerView = UIView()
        topLeftCornerView.layer.addSublayer(CAShapeLayer())
        topLeftCornerTouchView.addSubview(topLeftCornerView)
        
        topRightCornerTouchView  = UIView()
        addSubview(topRightCornerTouchView)
        
        topRightCornerView = UIView()
        topRightCornerView.layer.addSublayer(CAShapeLayer())
        topRightCornerTouchView.addSubview(topRightCornerView)
        
        bottomRightCornerTouchView  = UIView()
        addSubview(bottomRightCornerTouchView)
        
        bottomRightCornerView = UIView()
        bottomRightCornerView.layer.addSublayer(CAShapeLayer())
        bottomRightCornerTouchView.addSubview(bottomRightCornerView)
        
        bottomLeftCornerTouchView  = UIView()
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
    
    //  MARK: - Life cycle
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        overlayView.frame = frame
        containerImageView.frame = cropRect
        matchForegroundToBackgroundScrollViewOffset()
        matchForegroundToBackgroundScrollViewSize()
        
        topEdgeTouchView.frame = cropAreaTopEdgeFrame
        layoutTopEdgeView(topEdgeView,
                          inTouchView: topEdgeTouchView,
                          forState: activeCropAreaPart == .topEdge
                            ? .highlighted
                            : .normal)
        
        rightEdgeTouchView.frame = cropAreaRightEdgeFrame
        layoutRightEdgeView(rightEdgeView,
                            inTouchView: rightEdgeTouchView,
                            forState: activeCropAreaPart == .rightEdge
                                ? .highlighted
                                : .normal)
        
        bottomEdgeTouchView.frame = cropAreaBottomEdgeFrame
        layoutBottomEdgeView(bottomEdgeView,
                             inTouchView: bottomEdgeTouchView,
                             forState: activeCropAreaPart == .bottomEdge
                                ? .highlighted
                                : .normal)
        
        leftEdgeTouchView.frame = cropAreaLeftEdgeFrame
        layoutLeftEdgeView(leftEdgeView,
                           inTouchView: leftEdgeTouchView,
                           forState: activeCropAreaPart == .leftEdge
                            ? .highlighted
                            : .normal)
        
        topLeftCornerTouchView.frame = cropAreaTopLeftCornerFrame
        layoutTopLeftCornerView(topLeftCornerView,
                                inTouchView: topLeftCornerTouchView,
                                forState: activeCropAreaPart == .topLeftCorner
                                    ? .highlighted
                                    : .normal)
        
        topRightCornerTouchView.frame = cropAreaTopRightCornerFrame
        layoutTopRightCornerView(topRightCornerView,
                                 inTouchView: topRightCornerTouchView,
                                 forState: activeCropAreaPart == .topRightCorner
                                    ? .highlighted
                                    : .normal)
        
        bottomRightCornerTouchView.frame = cropAreaBottomRightCornerFrame
        layoutBottomRightCornerView(bottomRightCornerView,
                                    inTouchView: bottomRightCornerTouchView,
                                    forState: activeCropAreaPart == .bottomRightCorner
                                        ? .highlighted
                                        : .normal)
        
        bottomLeftCornerTouchView.frame = cropAreaBottomLeftCornerFrame
        layoutBottomLeftCornerView(bottomLeftCornerView,
                                   inTouchView: bottomLeftCornerTouchView,
                                   forState: activeCropAreaPart == .bottomLeftCorner
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
            return .topEdge
        } else if cropAreaBottomEdgeFrame.contains(point) {
            return .bottomEdge
        } else if cropAreaRightEdgeFrame.contains(point) {
            return .rightEdge
        } else if cropAreaLeftEdgeFrame.contains(point) {
            return .leftEdge
        } else if cropAreaTopLeftCornerFrame.contains(point) {
            return .topLeftCorner
        } else if cropAreaTopRightCornerFrame.contains(point) {
            return .topRightCorner
        } else if cropAreaBottomLeftCornerFrame.contains(point) {
            return .bottomLeftCorner
        } else if cropAreaBottomRightCornerFrame.contains(point) {
            return .bottomRightCorner
        } else {
            return .none
        }
    }
    
    // MARK: Other methods
    
    final func showOverlayBlur(_ show: Bool, completion: ((Bool) -> Void)? = nil) {

        UIView.animate(withDuration: configuraiton.animation.duration, delay: 0, options: [], animations: {
           
                self.overlayView.subviews.first?.alpha = show ? self.configuraiton.overlay.blurAlpha : 0.0

        }, completion: { isComplete in
            completion?(isComplete)
        })
    }
    
    final func showGrid(_ show: Bool, completion: ((Bool) -> Void)? = nil) {
        
        if configuraiton.grid.alwaysShowGrid {
             completion?(true)
            return
        }
        
        let animations: () -> Void = { 
            self.gridView.alpha = show ? 1 : 0
        }
        
        if configuraiton.animation.duration == 0 {
            
            animations()
            
        } else {
        
            UIView.animate(withDuration: configuraiton.animation.duration, delay: 0, options: [], animations: animations, completion: { isComplete in
                completion?(isComplete)
            })
        }
    }
    
    /**
     Visual representation for top edge view in current user interaction state.
     
     - Parameter view: Top edge view.
     
     - Parameter touchView: Touch area view where added top edge view.
     
     - Parameter state: User interaction state.
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
     
     - Parameter view: Right edge view.
     
     - Parameter touchView: Touch area view where added right edge view.
     
     - Parameter state: User interaction state.
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
     
     - Parameter view: Bottom edge view.
     
     - Parameter touchView: Touch area view where added bottom edge view.
     
     - Parameter state: User interaction state.
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
     
     - Parameter view: Left edge view.
     
     - Parameter touchView: Touch area view where added left edge view.
     
     - Parameter state: User interaction state.
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
     
     - Parameter view: Top left corner view.
     
     - Parameter touchView: Touch area view where added top left edge view.
     
     - Parameter state: User interaction state.
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
     
     - Parameter view: Top right corner view.
     
     - Parameter touchView: Touch area view where added top right edge view.
     
     - Parameter state: User interaction state.
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
     
     - Parameter view: Bottom right corner view.
     
     - Parameter touchView: Touch area view where added bottom right edge view.
     
     - Parameter state: User interaction state.
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
     
     - Parameter view: Bottom left corner view.
     
     - Parameter touchView: Touch area view where added bottom left edge view.
     
     - Parameter state: User interaction state.
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
     
     - Parameter view: Grid view.
     
     - Parameter gridViewHorizontalLines: Horizontal line view`s array.
     
     - Parameter gridViewVerticalLines: Vertical line view`s array.
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
    
    // MARK: - Touches
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {  return }
        
        /* Save */
        
        touchesBegan = (touch.location(in: self), cropRect)

        /* Active part */
        
        activeCropAreaPart = getCropAreaPartContainsPoint(touchesBegan.touch)
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
  
        guard let touch = touches.first else { return }

        /* GET TRANSLATION POINT */
   
        let point = touch.location(in: self)
        let previousPoint = touch.previousLocation(in: self)
        
        let translationPoint = CGPoint(x: point.x - previousPoint.x, y: point.y - previousPoint.y)
        
        /* MOVE FRAME */
        
        let cropRectMaxFrame = cropperView.reversedFrameWithInsets
        
        if activeCropAreaPart.contains(.topEdge) {
            
            cropRect.origin.y += translationPoint.y
            cropRect.size.height -= translationPoint.y
            
            let pointInEdge = touchesBegan.touch.y - touchesBegan.cropRect.minY
            let minStickPoint = pointInEdge + cropRectMaxFrame.minY
            let maxStickPoint = pointInEdge + touchesBegan.cropRect.maxY - configuraiton.minCropRectSize.height
            
            if point.y > maxStickPoint || cropRect.height < configuraiton.minCropRectSize.height {
                cropRect.origin.y = touchesBegan.cropRect.maxY - configuraiton.minCropRectSize.height
                cropRect.size.height = configuraiton.minCropRectSize.height
            }
            
            if point.y < minStickPoint {
                cropRect.origin.y = cropRectMaxFrame.minY
                cropRect.size.height = touchesBegan.cropRect.maxY - cropRectMaxFrame.minY
            }
        }
        
        if activeCropAreaPart.contains(.rightEdge) {
            
            cropRect.size.width += translationPoint.x
            
            let pointInEdge = touchesBegan.touch.x - touchesBegan.cropRect.maxX
            let minStickPoint = pointInEdge + touchesBegan.cropRect.minX + configuraiton.minCropRectSize.width
            let maxStickPoint = pointInEdge + cropRectMaxFrame.maxX
            
            if  point.x > maxStickPoint {
                cropRect.size.width =  cropRectMaxFrame.maxX - cropRect.origin.x
            }
            
            if point.x < minStickPoint || cropRect.width < configuraiton.minCropRectSize.width {
                cropRect.size.width = configuraiton.minCropRectSize.width
            }
        }
        
        if activeCropAreaPart.contains(.bottomEdge) {

            cropRect.size.height += translationPoint.y
            
            let pointInEdge = touchesBegan.touch.y - touchesBegan.cropRect.maxY
            let minStickPoint = pointInEdge + touchesBegan.cropRect.minY + configuraiton.minCropRectSize.height
            let maxStickPoint = pointInEdge + cropRectMaxFrame.maxY
            
            if  point.y > maxStickPoint {
                cropRect.size.height = cropRectMaxFrame.maxY - cropRect.origin.y
            }
            
            if point.y < minStickPoint || cropRect.height < configuraiton.minCropRectSize.height {
                cropRect.size.height = configuraiton.minCropRectSize.height
            }
        }
        
        if activeCropAreaPart.contains(.leftEdge) {
            
            cropRect.origin.x += translationPoint.x
            cropRect.size.width -= translationPoint.x
            
            let pointInEdge = touchesBegan.touch.x - touchesBegan.cropRect.minX
            let minStickPoint = pointInEdge + cropRectMaxFrame.minX
            let maxStickPoint = pointInEdge + touchesBegan.cropRect.maxX - configuraiton.minCropRectSize.width
            
            if  point.x > maxStickPoint || cropRect.width < configuraiton.minCropRectSize.width {
                cropRect.origin.x = touchesBegan.cropRect.maxX - configuraiton.minCropRectSize.width
                cropRect.size.width = configuraiton.minCropRectSize.width
            }
            
            if point.x < minStickPoint {
                cropRect.origin.x = cropRectMaxFrame.minX
                cropRect.size.width = touchesBegan.cropRect.maxX - cropRectMaxFrame.minX
            }
        }

        /* Update UI for the crop rectange */
        
        layoutSubviews()
        
        /* Delegates */
        
        delegate?.cropperOverlayViewDidChangeCropRect(self, cropRect)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        /* Active part */
        
        activeCropAreaPart = .none
    }
    
    // MARK: - Instance Method
    
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
                
        guard alpha == 1 else { return cropperView.scrollView }
        
        return self.point(inside: point, with: event) && getCropAreaPartContainsPoint(point) != .none
            ? self
            : cropperView.scrollView
    }
    
    // MARK: - Match Foreground To Background
    
    func matchForegroundToBackgroundScrollViewOffset() {
        imageView.frame.origin = CGPoint(
            x: -(cropperView.scrollView.contentOffset.x + containerImageView.frame.origin.x),
            y: -(cropperView.scrollView.contentOffset.y + containerImageView.frame.origin.y))
    }
    
    func matchForegroundToBackgroundScrollViewSize() {
        imageView.frame.size = cropperView.scrollView.contentSize
    }
}
