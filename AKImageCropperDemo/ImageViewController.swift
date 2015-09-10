//
//  ImageViewController.swift
//  AKImageCropperDemo
//  GitHub: https://github.com/artemkrachulov/AKImageCropper
//
//  Created by Krachulov Artem
//  Copyright (c) 2015 Krachulov Artem. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//

import UIKit

class ImageViewController: UIViewController {
    
    var _image: UIImage!
    
    // MARK: - Components
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Life Cycle
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    override func viewDidLoad() {
        super.viewDidLoad()
                    
        imageView.image = _image
    }
}
