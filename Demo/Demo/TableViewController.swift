//
//  TableViewController.swift
//
//  Created by Artem Krachulov.
//  Copyright (c) 2016 Artem Krachulov. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//

import UIKit

class TableViewController: UITableViewController {
  
  //  MARK: - Variables

  let imagesList = [
    ["Attractive-girl","Autumn-background", "Colorful-pillows"],
    ["Cupcakes","Funnel-cake-stand", "Image-of-earth"]
  ]
  
  // MARK: - Table view data source
  //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return section == 0 ? "Large" : "Small"
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return imagesList.count
  }
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return imagesList[section].count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier("image", forIndexPath: indexPath)
    
    let name = imagesList[indexPath.section][indexPath.row]
    let image = UIImage(named: name)
    
    // Configure the cell...
    cell.textLabel!.text = name.componentsSeparatedByString("-").joinWithSeparator(" ")
    cell.detailTextLabel?.text = String(format: "Size %0.1f x %0.1f", image?.size.width as CGFloat!, image?.size.height as CGFloat!)
    
    return cell
  }
  
  //  MARK: - Navigation
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    let selectedPath = tableView.indexPathForSelectedRow as NSIndexPath!
    
    if let vc = segue.destinationViewController as? CropperViewController {
      vc.image = UIImage(named: imagesList[selectedPath.section][selectedPath.row])
    }
  }
}
