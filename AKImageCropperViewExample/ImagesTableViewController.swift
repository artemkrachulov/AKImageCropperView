//
//  ImagesTableViewController.swift
//
//  Created by Artem Krachulov.
//  Copyright (c) 2016 Artem Krachulov. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//

import UIKit

final class ImagesTableViewController: UITableViewController {
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let selectedPath = tableView.indexPathForSelectedRow!
        
        (segue.destination as! CropperViewController).image = UIImage(named: Constants.images[selectedPath.section][selectedPath.row])
    }
}

// MARK: - Table view data source

extension ImagesTableViewController {
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return section == 0 ? "Large" : "Small"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return Constants.images.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Constants.images[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "image", for: indexPath)
        
        let name = Constants.images[indexPath.section][indexPath.row]
        let image = UIImage(named: name)
        
        // Configure the cell...
        
        cell.textLabel!.text = name.components(separatedBy: "-").joined(separator: " ")
        cell.detailTextLabel?.text = ""
        if let image = image {
            cell.detailTextLabel?.text = String(format: "Size %0.1f x %0.1f", image.size.width, image.size.height)
        }
        
        return cell
    }
}
