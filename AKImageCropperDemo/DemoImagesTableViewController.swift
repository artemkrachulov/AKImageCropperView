//
//  DemoImagesTableViewController.swift
//  AKImageCropperDemo
//
//  Created by Krachulov Artem
//  Copyright (c) 2015 Krachulov Artem. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//

import UIKit

class DemoImagesTableViewController: UITableViewController {
    
    // MARK: - Demo images
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    let images = [
        ["Attractive-girl","Autumn-background", "Colorful-pillows"],
        ["Cupcakes","Funnel-cake-stand", "Image-of-earth"]
    ]
    
    // MARK: - Table view data source
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return section == 0 ? "Large" : "Small"
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return images.count
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return images[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                
        let cell = tableView.dequeueReusableCellWithIdentifier("image", forIndexPath: indexPath) as! UITableViewCell
        
        let name = images[indexPath.section][indexPath.row]
        let image = UIImage(named: name)

        // Configure the cell...
        cell.textLabel!.text = " ".join(name.componentsSeparatedByString("-"))
        cell.detailTextLabel?.text = String(format: "Size %0.1f x %0.1f", image?.size.width as CGFloat!, image?.size.height as CGFloat!)
        
        return cell
    }
    
    // MARK: - Navigation
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let selectedPath = tableView.indexPathForSelectedRow() as NSIndexPath!

        if let vc = segue.destinationViewController as? CropperViewController {
            
            vc._image = UIImage(named: images[selectedPath.section][selectedPath.row])
        }
    }
    
    // MARK: - Actions
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    @IBAction func closeBtn(sender: UIBarButtonItem) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
