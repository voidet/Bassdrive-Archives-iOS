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
            destVC.sets = self.sets![key!]
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
        let cell:RSSetTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! RSSetTableViewCell
        if (cell.cellType == .MediaFile) {
            
        }
    }

}