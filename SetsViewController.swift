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
            cell.cellType = .MediaFile
            
            var bassdriveSet = BassdriveSet()
            let title:String = self.sets?.arrayObject![indexPath.row] as! String
            bassdriveSet.bassdriveSetTitle = title
            bassdriveSet.bassdriveSetUrlString = title
            cell.bassdriveSet = bassdriveSet
            
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell:RSSetTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! RSSetTableViewCell
        if (cell.cellType == .MediaFile) {
            
        }
        self.tableView.deselectRowAtIndexPath(self.tableView.indexPathForSelectedRow()!, animated: true)
        
        if let bassdriveSet = cell.bassdriveSet {
            if (bassdriveSet.exists()) {
                // start playing
            } else {
                // start downloading
                RSDownloadManager.sharedManager.enqueForDownload(bassdriveSet)
            }
        }
       
    }

}