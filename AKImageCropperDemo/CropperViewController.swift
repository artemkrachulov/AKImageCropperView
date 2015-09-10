//
//  CropperViewController.swift
//  AKImageCropperDemo
//
//  Created by Krachulov Artem
//  Copyright (c) 2015 Krachulov Artem. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//

import UIKit

class CropperViewController: UIViewController {
    
    // MARK: - Components
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    var _image: UIImage!
    
    @IBOutlet weak var showHideBtn: UIButton!
    @IBOutlet weak var cropBtn: UIButton!
    
    @IBOutlet weak var cropView: AKImageCropperView!
    
    var cropViewProgrammatically: AKImageCropperView!
    
    // MARK: - Life Cycle
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cropView.image = _image
        cropView.delegate = self
        
//        cropView.scrollView.delegate = self
        
      
        

        cropView.removeFromSuperview()
        
        

        let frame = CGRectMake(0, 0, 300, 300)
        cropViewProgrammatically = AKImageCropperView(frame: frame, image: _image, showOverlayView: false)
        
        
        view.addSubview(cropViewProgrammatically)
        
        // initialize Crop View programmatically
        /*cropViewProgrammatically = AKImageCropperView(image: _image, showOverlayView: false)
        cropViewProgrammatically.delegate = self
        cropViewProgrammatically.setTranslatesAutoresizingMaskIntoConstraints(false)

        view.addSubview(cropViewProgrammatically)

        let right = NSLayoutConstraint(item: cropViewProgrammatically, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: -20)
        let left = NSLayoutConstraint(item: cropViewProgrammatically, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 20)
        let top = NSLayoutConstraint(item: cropViewProgrammatically, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: topLayoutGuide, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 20)
        let bottom = NSLayoutConstraint(item: cropViewProgrammatically, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: showHideBtn, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)

        view.addConstraint(right)
        view.addConstraint(left)
        view.addConstraint(top)
        view.addConstraint(bottom)
        
        var leftBtn = NSLayoutConstraint(item: cropBtn, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: cropViewProgrammatically, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
    
        view.addConstraint(leftBtn)
     
        var rightBtn = NSLayoutConstraint(item: showHideBtn, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: cropViewProgrammatically, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0)
        
        view.addConstraint(rightBtn)*/

    
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        /**
            
            Switch cropView to cropViewProgrammatically
            if you suing programmatically initalisation
        
        */
        
        cropView.refresh()
        
        cropViewProgrammatically.refresh()
    
    }
    
    // MARK: - Button Actions
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _    
    
    @IBAction func showHideFrameBtn(sender: UIButton) {
        
        /**
        
            Switch cropView to cropViewProgrammatically
            if you suing programmatically initalisation
        
        */
        if cropView.overlayViewIsActive {
            
            showHideBtn.setTitle("Show Crop Frame", forState: UIControlState.Normal)
            
            cropView.dismissOverlayViewAnimated(true) { () -> Void in
                
                println("Frame disabled")
            }
        } else {
            
            showHideBtn.setTitle("Hide Crop Frame", forState: UIControlState.Normal)
            
            cropView.showOverlayViewAnimated(true, withCropFrame: nil, completion: { () -> Void in
                
                println("Frame active")
            })
        }
        
    }
    
    @IBAction func cropTestBtn(sender: UIBarButtonItem) {
        
        cropView.setCropRect(CGRectMake(50, 50, 150, 150))
    }
    
    
    // MARK: - Navigation
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let vc = segue.destinationViewController as? ImageViewController {
            
            vc._image = cropView.croppedImage()
        }
    }
}

// MARK: - AKImageCropperDelegate
//         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

extension CropperViewController: AKImageCropperViewDelegate {
    
    func cropRectChanged(rect: CGRect) {
        
        println("New crop rectangle: \(rect)")
    }
    
    /*func croperViewDidChangeCropRect(cropRect: CGRect, translatedToImageRect imageRect: CGRect) {
        
        println("Crop rectangle has been changed: \(cropRect)")
        println("Image crop rectangle has been changed: \(imageRect)")
    }
    
    func cropperViewDidScroll(scrollView: UIScrollView, cropRect: CGRect, translatedToImageRect imageRect: CGRect) {
        
        println("Image has been scrolled: \(scrollView.contentOffset)")
        println("Crop rectangle has been changed: \(cropRect)")
        println("Image crop rectangle has been changed: \(imageRect)")
    }
    
    func cropperViewDidZoom(scrollView: UIScrollView, cropRect: CGRect, translatedToImageRect imageRect: CGRect) {
        
        println("Image has been zoomed: \(scrollView.zoomScale)")
        println("Crop rectangle has been changed: \(cropRect)")
        println("Image crop rectangle has been changed: \(imageRect)")
    }*/
}

extension CropperViewController: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        
        return cropView.imageView
    }
}
