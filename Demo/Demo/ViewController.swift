//
//  ViewController.swift
//
//  Created by Artem Krachulov.
//  Copyright (c) 2016 Artem Krachulov. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//

import UIKit

class ViewController: UIViewController {
  
  //  MARK: - Objects
  
  var imagePicker = UIImagePickerController()
}

//  MARK: - UIImagePickerControllerDelegate

extension ViewController: UIImagePickerControllerDelegate {
  
  @IBAction func galleryAction() {
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
      
      imagePicker.delegate = self
      imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
      imagePicker.allowsEditing = false
      
      presentViewController(imagePicker, animated: true, completion: nil)
    }
  }
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      
      let cropperViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("cropper-vc") as! CropperViewController
      cropperViewController.image = pickedImage
      
      picker.pushViewController(cropperViewController, animated: true)
    }
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    dismissViewControllerAnimated(true, completion: nil)
  }
}

extension ViewController: UINavigationControllerDelegate {}