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
            Alamofire.request(.GET, self.requestURL).responseJSON { _, _, responseJSON, error in
                if let sets = responseJSON as? Dictionary<String, AnyObject> {
                    self.sets = JSON(sets)
                }
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (self.sets?["_sets"] != nil) ? 2 : 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (self.sets == nil) {
            return 0;
        }
        
        var count = 0
        if (section == 0) {
            count = self.sets!.count
            count -= (self.sets?["_sets"] != nil) ? 1 : 0
        } else if (section == 1) {
            return self.sets?["_sets"].count ?? 0
        }
        
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell:RSSetTableViewCell = tableView.dequeueReusableCellWithIdentifier("setTitleCell") as! RSSetTableViewCell
    
        if (indexPath.section == 0) {
            let keys = self.sets?.dictionaryObject?.keys
            var row = indexPath.row

            var key:String? = keys?.array[row]
            while (key == "_sets") {
                key = keys!.array[row++]
            }

            cell.bassdriveSetTitleLabel.text = key
            cell.cellType = .Folder
        } else if (indexPath.section == 1) {
            cell.cellType = .MediaFile
            
            if let setDict = self.sets?["_sets"].arrayObject![indexPath.row] as? Dictionary<String, String> {
                var bassdriveSet = BassdriveSet(dict: setDict)
                
                if (bassdriveSet.exists()) {
                    cell.backgroundColor = UIColor.redColor()
                }
                
                cell.bassdriveSetTitleLabel.text = bassdriveSet.fileName()
                cell.bassdriveSet = bassdriveSet
                
                cell.downloadTask = RSDownloadManager.sharedManager.jobForBassdriveSet(bassdriveSet)
            }

        }
        
        return cell
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        
        if (identifier == "goToSetList") {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let cell:RSSetTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! RSSetTableViewCell
                if (cell.cellType == .MediaFile && !cell.bassdriveSet!.exists()) {
                    return false
                }
            }
        }
        
        return true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell:RSSetTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! RSSetTableViewCell
        if (cell.cellType == .MediaFile) {
            
        }
        self.tableView.deselectRowAtIndexPath(self.tableView.indexPathForSelectedRow()!, animated: true)
        
        if let bassdriveSet = cell.bassdriveSet {
            if (bassdriveSet.exists()) {
                RSPlaybackManager.sharedInstance.playSet(bassdriveSet)
            } else {
                cell.downloadTask = RSDownloadManager.sharedManager.enqueForDownload(bassdriveSet)
            }
        }
       
    }

}