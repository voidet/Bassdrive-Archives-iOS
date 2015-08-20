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
import RxSwift
import RxCocoa

class SetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var sets:JSON?
    var downloadedSets:[BassdriveSet]?
    #if DEBUG
    let requestURL:String = "http://localhost:8080/parse.php"
    #else
    let requestURL:String = "http://jotlab.com/bassdrive/parse.php"
    #endif
    
    @IBOutlet var tableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.layoutMargins = UIEdgeInsetsZero
        
        self.setupTitleView()
        
        self.rx_observeWeakly("sets")
            >- subscribeNext { (sets:JSON?) in
                self.tableView.reloadData()
            }
        
        if (self.sets == nil) {
            self.restoreAndRefreshSets()
        }
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        if (self !== self.navigationController?.childViewControllers.first) {
            self.navigationItem.leftBarButtonItem = nil;
        }
        
    }
    
    private func restoreAndRefreshSets() {
        if let json:AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("sets") {
            self.sets = JSON(json)
        }
        
        Alamofire.request(.GET, self.requestURL).responseJSON { _, _, responseJSON, error in
            if let sets = responseJSON as? Dictionary<String, AnyObject> {
                self.sets = JSON(sets)
                NSUserDefaults.standardUserDefaults().setObject(responseJSON, forKey: "sets")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }
    
    private func setupTitleView() {
        var titleView = UIImageView(image: UIImage(named: "titleView"))
        titleView.frame.size.height = 40
        titleView.contentMode = .ScaleAspectFit
        titleView.clipsToBounds = true
        self.navigationItem.titleView = titleView
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "goToSetList") {
            let destVC:SetsViewController = segue.destinationViewController as! SetsViewController
            let indexPath:NSIndexPath = self.tableView.indexPathForSelectedRow()!

            var key:String? = self.sets?.dictionaryObject?.keys.array[indexPath.row] ?? ""
            destVC.sets = self.sets![key!]
            destVC.title = key
        } else if (segue.identifier == "showDownloadedSets") {
            let destVC:SetsViewController = segue.destinationViewController as! SetsViewController
            destVC.downloadedSets = SetsHelper.getDownloadedSets()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if (self.downloadedSets != nil) {
            return 1
        }
        
        return (self.sets?["_sets"] != nil) ? 2 : 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        if (self.downloadedSets != nil) {
            return self.downloadedSets?.count ?? 0
        }
        
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
        if (self.downloadedSets != nil) {
            cell = self.getLocalSetCell(indexPath, cell:cell)
        } else if (self.sets != nil) {
            cell = self.getRemoteSetCell(indexPath, cell:cell)
        }
        
        return cell
    }
    
    func getLocalSetCell(indexPath:NSIndexPath, cell:RSSetTableViewCell) -> RSSetTableViewCell {
        
        cell.progressBarSize.constant = self.view.frame.size.width
        
        cell.cellType = .MediaFile
            
        let bassdriveSet = self.downloadedSets![indexPath.row]
        cell.bassdriveSetTitleLabel.text = bassdriveSet.fileName()
        cell.downloaded.alpha = 1
        cell.bassdriveSet = bassdriveSet
        cell.previouslyListened.alpha = bassdriveSet.hasPreviouslyListened() ? 1 : 0
        
        return cell
    }
    
    func getRemoteSetCell(indexPath:NSIndexPath, cell:RSSetTableViewCell) -> RSSetTableViewCell {
        
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