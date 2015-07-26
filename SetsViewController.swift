//
//  SetsViewController.swift
//  Bassdrive
//
//  Created by Katherine Siegal on 7/25/15.
//  Copyright (c) 2015 Richard Sbresny. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var sets:JSON?
    var data = [1 : "link 1", 2 : "link 2", 3 : "link 3"]
    let requestURL:String = "http://localhost:8080/parse.php"
    
    @IBOutlet var tableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.sets == nil) {
            Alamofire.request(.GET, requestURL).responseJSON { _, _, responseJSON, _ in
                self.sets = JSON(responseJSON!)
                self.tableView.reloadData()
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "goToSetList") {
            let destVC:SetsViewController = segue.destinationViewController as! SetsViewController
            let indexPath:NSIndexPath = self.tableView.indexPathForSelectedRow()!

            var key:String? = self.sets?.dictionaryObject?.keys.array[indexPath.row] ?? ""
            println(key)
            destVC.sets = self.sets![key!]
            println(destVC.sets)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.sets?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell:RSSetTableViewCell = tableView.dequeueReusableCellWithIdentifier("setTitleCell") as! RSSetTableViewCell
        
        var type = self.sets?.type
        if (type == .Dictionary) {
            let key:String = self.sets?.dictionaryObject?.keys.array[indexPath.row] ?? ""
            cell.bassdriveSetTitleLabel.text = key
            cell.cellType = .Folder
        } else if (type == .Array) {
            cell.bassdriveSetTitleLabel.text = self.sets?.arrayObject![indexPath.row] as? String ?? ""
            cell.cellType = .MediaFile
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}