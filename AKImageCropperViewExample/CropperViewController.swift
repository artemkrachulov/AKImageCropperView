//
//  CropperViewController.swift
//
//  Created by Artem Krachulov.
//  Copyright (c) 2016 Artem Krachulov. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//

import UIKit
import AKImageCropperView

final class CropperViewController: UIViewController {
    
    //  MARK: - Properties
    
    var image: UIImage!
    
    // MARK: - Connections:
    
    // MARK: -- Outlets
    
    private var cropView: AKImageCropperView {
        return cropViewProgrammatically ?? cropViewStoryboard
    }
    
    @IBOutlet weak var cropViewStoryboard: AKImageCropperView!
    private var cropViewProgrammatically: AKImageCropperView!
    
    @IBOutlet weak var overlayActionView: UIView!
    
    @IBOutlet weak var navigationView: UIView!
    
    // MARK: -- Actions
    
    @IBAction func backAction(_ sender: AnyObject) {
        
        guard !cropView.isEdited else {
            
            let alertController = UIAlertController(title: "Warning!", message:
                "All changes will be lost.", preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.cancel, handler: { _ in
                
                _ = self.navigationController?.popViewController(animated: true)
            }))
            
            alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
            
            present(alertController, animated: true, completion: nil)
            return
        }
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cropRandomAction(_ sender: AnyObject) {
        
//        cropView.setCropRectAnin(CGRect(x: 50, y: 200, width: 100, height: 100))
        
        
        /*
         let randomWidth = max(UInt32(cropView.configuration.cropRect.minimumSize.width), arc4random_uniform(UInt32(cropView.scrollView.frame.size.width)))
         let randomHeight = max(UInt32(cropView.configuration.cropRect.minimumSize.height), arc4random_uniform(UInt32(cropView.scrollView.frame.size.height)))
         let offsetX = CGFloat(arc4random_uniform(UInt32(cropView.scrollView.frame.size.width) - randomWidth))
         let offsetY = CGFloat(arc4random_uniform(UInt32(cropView.scrollView.frame.size.height) - randomHeight))
         
         cropView.cropRect(CGRectMake(offsetX, offsetY, CGFloat(randomWidth), CGFloat(randomHeight)))*/
    }
    
    @IBAction func randomImageAction(_ sender: AnyObject) {
        let images = Constants.images.flatMap { $0 }
        cropView.image = UIImage(named: images[Int(arc4random_uniform(UInt32(images.count)))])        
        angle = 0.0
    }
    
    @IBAction func cropImageAction(_ sender: AnyObject) {
        
         guard let image = cropView.croppedImage else {
            return
         }
         
         let imageViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageViewController") as! ImageViewController
         imageViewController.image = image
         navigationController?.pushViewController(imageViewController, animated: true)
    }
    
    @IBAction func showHideOverlayAction(_ sender: AnyObject) {
        
        if cropView.isOverlayViewActive {
            
            cropView.hideOverlayView(animationDuration: 0.3)
            
            UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
                self.overlayActionView.alpha = 0
                
            }, completion: nil)
            
        } else {
            
            cropView.showOverlayView(animationDuration: 0.3)
            
            UIView.animate(withDuration: 0.3, delay: 0.3, options: UIViewAnimationOptions.curveLinear, animations: {
                self.overlayActionView.alpha = 1
                
            }, completion: nil)
            
        }
    }
    
    var angle: Double = 0.0
    
    @IBAction func rotateAction(_ sender: AnyObject) {

        angle += M_PI_2
        
        cropView.rotate(angle, withDuration: 0.3, completion: { _ in
            
            if self.angle == 2 * M_PI {
                self.angle = 0.0
            }
        })
    }
    
    @IBAction func resetAction(_ sender: AnyObject) {
        
        cropView.reset(animationDuration: 0.3)
        angle = 0.0
    }
    
    // MARK: -  Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true

        // Programmatically initialization
        
        /*
        cropViewProgrammatically = AKImageCropperView()
        */
        
        // iPhone 4.7"
        
        /*
        cropViewProgrammatically = AKImageCropperView(frame: CGRect(x: 0, y: 20.0, width: 375.0, height: 607.0))
        view.addSubview(cropViewProgrammatically)
        */
        
        // with constraints
        
        /*
        cropViewProgrammatically = AKImageCropperView()
        cropViewProgrammatically.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cropViewProgrammatically)
        
        if #available(iOS 9.0, *) {
            
            cropViewProgrammatically.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            cropViewProgrammatically.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            topLayoutGuide.bottomAnchor.constraint(equalTo: cropViewProgrammatically.topAnchor).isActive = true
            cropViewProgrammatically.bottomAnchor.constraint(equalTo: navigationView.topAnchor).isActive = true
            
        } else {
            
            for attribute: NSLayoutAttribute in [.top, .left, .bottom, .right] {
                
                var toItem: Any?
                var toAttribute: NSLayoutAttribute!
                
                if attribute == .top {
                    
                    toItem = topLayoutGuide
                    toAttribute = .bottom
                    
                } else if attribute == .bottom {
                    
                    toItem = navigationView
                    toAttribute = .top
                } else {
                    toItem = view
                    toAttribute = attribute
                }
                
                view.addConstraint(
                    NSLayoutConstraint(
                        item: cropViewProgrammatically,
                        attribute: attribute,
                        relatedBy: NSLayoutRelation.equal,
                        toItem: toItem,
                        attribute: toAttribute,
                        multiplier: 1.0, constant: 0))
            }
        }
        */
        

        // Inset for overlay action view
        
        /*
        cropView.overlayView?.configuraiton.cropRectInsets.bottom = 50
        */
        
        // Custom overlay view configuration
        
        /*
        var customConfiguraiton = AKImageCropperCropViewConfiguration()
            customConfiguraiton.cropRectInsets.bottom = 50
        cropView.overlayView = CustomImageCropperOverlayView(configuraiton: customConfiguraiton)
        */
        
        cropView.delegate = self
        cropView.image = image
    }
}

//  MARK: - AKImageCropperViewDelegate

extension CropperViewController: AKImageCropperViewDelegate {
    
    func imageCropperViewDidChangeCropRect(view: AKImageCropperView, cropRect rect: CGRect) {
//        print("New crop rectangle: \(rect)")
    }

}
