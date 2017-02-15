//
//  ImageViewController.swift
//
//  Created by Artem Krachulov.
//  Copyright (c) 2016 Artem Krachulov. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//

import UIKit

final class ImageViewController: UIViewController {
    
    // MARK: - Properties
    
    var image: UIImage!
    
    // MARK: - Connections:
    
    // MARK: -- Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: -- Actions
    
    @IBAction func backAction(_ sender: UIButton) {
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showListAction(_ sender: UIButton) {
        
        if presentingViewController != nil {
            
            _ = navigationController?.popToRootViewController(animated: true)

        } else {
        
            _ = navigationController?.popToViewController(navigationController!.viewControllers[1], animated: true)
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image
    }
}
