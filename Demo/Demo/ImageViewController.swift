//
//  ImageViewController.swift
//
//  Created by Artem Krachulov.
//  Copyright (c) 2016 Artem Krachulov. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//

import UIKit

class ImageViewController: UIViewController {
  
  //  MARK: - Properties
  
  var image: UIImage!
  
  //  MARK: - Outlets
  
  @IBOutlet weak var imageView: UIImageView!
  
  //  MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    imageView.image = image
  }
}