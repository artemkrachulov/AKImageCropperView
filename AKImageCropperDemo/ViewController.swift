//
//  ViewController.swift
//  AKImageCropperDemo
//  GitHub: https://github.com/artemkrachulov/AKImageCropper
//
//  Created by Krachulov Artem
//  Copyright (c) 2015 Krachulov Artem. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Components
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    @IBOutlet var galleryBuuton: UIButton!
    @IBOutlet var demoFolderBuuton: UIButton!
    var imagePicker = UIImagePickerController()
}

// MARK: - UIImagePickerControllerDelegate
//         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBAction func galleryBuutonClicked(){        
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            imagePicker.navigationBar.translucent = false
            imagePicker.navigationBar.barStyle = .Black
            imagePicker.navigationBar.tintColor = UIColor.whiteColor()
            
            presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("cropper-vc") as! CropperViewController
                vc._image = pickedImage
            
            picker.pushViewController(vc, animated: true)
        }        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}

