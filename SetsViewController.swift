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
        self.tableView.layoutMargins = UIEdgeInsetsZero
        
        if (self.sets == nil) {
            
            var titleView = UIImageView(image: UIImage(named: "titleView"))
            titleView.frame.size.height = 40
            titleView.contentMode = .ScaleAspectFit
            titleView.clipsToBounds = true
            self.navigationItem.titleView = titleView
            
            if let json:AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("sets") {
                self.sets = JSON(json!)
                self.tableView.reloadData()
            }

            Alamofire.request(.GET, self.requestURL).responseJSON { _, _, responseJSON, error in
                if let sets = responseJSON as? Dictionary<String, AnyObject> {
                    self.sets = JSON(sets)
                    NSUserDefaults.standardUserDefaults().setObject(responseJSON, forKey: "sets")
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
                self.tableView.reloadData()
            }
        }
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "goToSetList") {
            let destVC:SetsViewController = segue.destinationViewController as! SetsViewController
            let indexPath:NSIndexPath = self.tableView.indexPathForSelectedRow()!

            var key:String? = self.sets?.dictionaryObject?.keys.array[indexPath.row] ?? ""
            destVC.sets = self.sets![key!]
            destVC.title = key
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
            let sets = self.sets?.dictionaryObject?.keys.array
            count = sets?.count ?? 0
            count -= (self.sets?.dictionaryObject?["_sets"] != nil) ? 1 : 0
        } else if (section == 1) {
            return self.sets?["_sets"].count ?? 0
        }
        
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell:RSSetTableViewCell = tableView.dequeueReusableCellWithIdentifier("setTitleCell") as! RSSetTableViewCell
        cell.progressBarSize.constant = self.view.frame.size.width
    
        if (indexPath.section == 0) {
            let keys = self.sets?.dictionaryObject?.keys.array
            var row = indexPath.row

            var key:String? = keys![row]
            while (key == "_sets") {
                key = keys![row++]
            }

            cell.bassdriveSetTitleLabel.text = key
            cell.cellType = .Folder
        } else if (indexPath.section == 1) {
            cell.cellType = .MediaFile
            
            if let setDict = self.sets?["_sets"].arrayObject![indexPath.row] as? Dictionary<String, String> {
                var bassdriveSet = BassdriveSet(dict: setDict)
                cell.bassdriveSetTitleLabel.text = bassdriveSet.fileName()
                cell.downloaded.alpha = bassdriveSet.exists() ? 1 : 0
                cell.bassdriveSet = bassdriveSet
                cell.downloadTask = RSDownloadManager.sharedManager.jobForBassdriveSet(bassdriveSet)
                cell.previouslyListened.alpha = bassdriveSet.hasPreviouslyListened() ? 1 : 0
            }

        }
        
        return cell
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        
        if (identifier == "goToSetList") {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let cell:RSSetTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! RSSetTableViewCell
                if (cell.cellType == .MediaFile) {
                    return false
                }
            }
        }
        
        return true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell:RSSetTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! RSSetTableViewCell
        
        if let bassdriveSet = cell.bassdriveSet {
            if (bassdriveSet.exists()) {
                RSPlaybackManager.sharedInstance.playSet(bassdriveSet)
            } else {
                cell.downloadTask = RSDownloadManager.sharedManager.enqueForDownload(bassdriveSet)
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
       
    }

}