//
//  CropperViewController.swift
//
//  Created by Artem Krachulov.
//  Copyright (c) 2016 Artem Krachulov. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//

import UIKit

class CropperViewController: UIViewController {
  
  
  //  MARK: - Outlets
  @IBOutlet weak var showHideBtn: UIButton!
  @IBOutlet weak var randImgBtn: UIButton!
  @IBOutlet weak var randRectBtn: UIButton!
  
  /// View initialized from storyboard.
  /// If you want inialize programmatically:
  ///   1. Delete AKImageCropperView from stotyboard
  ///   2. Remove "@IBOutlet weak " from this property
  ///
  @IBOutlet weak var cropView: AKImageCropperView! {
    didSet {
		    cropView.delegate = self
      cropView.cropRectDelegate = self
    }
  }
  
  //  MARK: - Properties
  
  var image: UIImage!
  let images = ["Attractive-girl", "Autumn-background", "Colorful-pillows","Cupcakes","Funnel-cake-stand", "Image-of-earth"]
  
  //  MARK: -  Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    cropView.configuration.cropRect.grid = false
    
//    cropView = AKImageCropperView()
    cropView.image = image
   
//    cropView.translatesAutoresizingMaskIntoConstraints = false
//    view.addSubview(cropView)
//    
//    view.addConstraints([
//      NSLayoutConstraint(item: cropView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: topLayoutGuide, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 20),
//      NSLayoutConstraint(item: cropView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: showHideBtn, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: randImgBtn, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: cropView, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: showHideBtn, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: cropView, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
//    ])
  }
  
  //  MARK: - Actions
  
  @IBAction func showHideAction(sender: UIButton) {

    if cropView.overlayIsActive {
      
      showHideBtn.setTitle("Show", forState: UIControlState.Normal)
      
      cropView.hideOverlayView(true) { () -> Void in
        self.randRectBtn.enabled = false
      }
    } else {
      showHideBtn.setTitle("Hide", forState: UIControlState.Normal)
      
      cropView.showOverlayView(true, completion: { () -> Void in
        self.randRectBtn.enabled = true
      })
    }
  }
  
  @IBAction func cropRandomAction(sender: AnyObject) {
    let randomWidth = max(UInt32(cropView.configuration.cropRect.minimumSize.width), arc4random_uniform(UInt32(cropView.scrollView.frame.size.width)))
    let randomHeight = max(UInt32(cropView.configuration.cropRect.minimumSize.height), arc4random_uniform(UInt32(cropView.scrollView.frame.size.height)))
    let offsetX = CGFloat(arc4random_uniform(UInt32(cropView.scrollView.frame.size.width) - randomWidth))
    let offsetY = CGFloat(arc4random_uniform(UInt32(cropView.scrollView.frame.size.height) - randomHeight))
    cropView.cropRect(CGRectMake(offsetX, offsetY, CGFloat(randomWidth), CGFloat(randomHeight)))
  }

  @IBAction func changeImgAction(sender: AnyObject) {
    cropView.image = UIImage(named: images[Int(arc4random_uniform(UInt32(images.count)))])
  }
  
  @IBAction func cropImgAction(sender: AnyObject) {
    /*
    guard let croppedImage = cropView.croppImage() else {
      return
    }
    
    let imageViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("image-vc") as! ImageViewController
    imageViewController.image = croppedImage
    
    navigationController?.pushViewController(imageViewController, animated: true) */
  }
}

//  MARK: - AKImageCropperViewDelegate

extension CropperViewController: AKImageCropperViewDelegate {
  func cropRectChanged(rect: CGRect) {
    print("New crop rectangle: \(rect)")
  }
}

extension CropperViewController: AKImageCropperCropRectDelegate { }