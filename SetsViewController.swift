//
//  SetsViewController.swift
//  Bassdrive
//
//  Created by Katherine Siegal on 7/25/15.
//  Copyright (c) 2015 Richard Sbresny. All rights reserved.
//

import UIKit

class SetsViewController: UIViewController, UITableViewDataSource {
    
    var sets:[AnyObject] = []
    
//    var data = [Int: string]()
//    
//    data[1] = "link 1"
//    data[2] = "link 2"
//    data[3] = "link 3"
    
    var data = [1 : "link 1", 2 : "link 2", 3 : "link 3"]
    
    @IBOutlet var tableView:UITableView!
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell:UITableViewCell = UITableViewCell()
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
}