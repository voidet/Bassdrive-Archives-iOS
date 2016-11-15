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
    
    #if DEBUG
    let requestURL:String = "http://localhost:8080/bassdrive.json"
    #else
    let requestURL:String = "http://jotlab.com/bassdrive.json"
    #endif
    
    var sets:JSON?
    var downloadedSets:[BassdriveSet]?

    dynamic var loadingSets:Bool = false
    let refreshControl = UIRefreshControl()
    
    @IBOutlet var tableView:UITableView!
    @IBOutlet var loadingView:UIView!
    @IBOutlet var loadingIndicator:UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.layoutMargins = UIEdgeInsets.zero
        
        self.setupTitleView()
    
        if (self.sets == nil && self.downloadedSets == nil) {
            self.loadingSets = true
            self.restoreAndRefreshSets()
        }
        
        self.loadingView.layer.cornerRadius = 10;
        
        self.rx_observe("loadingSets")
            .subscribeNext { (alpha:Bool?) in
                if (alpha!) {
                    self.loadingView.alpha = 1
                    self.loadingIndicator.startAnimating()
                } else {
                    self.loadingView.alpha = 0
                    self.loadingIndicator.stopAnimating()
                }
            }
        
        self.refreshControl.tintColor = UIColor(hex:"#FF36C1")
        self.refreshControl.rx_controlEvents(.ValueChanged)
            .subscribeNext {
                self.restoreAndRefreshSets()
            }
        self.tableView.addSubview(refreshControl)
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
        
        if (self !== self.navigationController?.childViewControllers.first) {
            self.navigationItem.leftBarButtonItem = nil;
        }
        
    }
    
    fileprivate func restoreAndRefreshSets() {
        if let json:AnyObject = UserDefaults.standard.object(forKey: "sets") as AnyObject? {
            self.sets = JSON(json)
            self.tableView.reloadData()
        }
        
        Alamofire.request(.GET, self.requestURL).responseJSON { _, _, responseJSON in
            self.loadingSets = false
            self.refreshControl.endRefreshing()
            if let sets = responseJSON.value as? Dictionary<String, AnyObject> {
                self.sets = JSON(sets)
                NSUserDefaults.standardUserDefaults().setObject(responseJSON.value, forKey: "sets")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.tableView.reloadData()
            }
        }
    }
    
    fileprivate func setupTitleView() {
        let titleView = UIImageView(image: UIImage(named: "titleView"))
        titleView.frame.size.height = 40
        titleView.contentMode = .scaleAspectFit
        titleView.clipsToBounds = true
        self.navigationItem.titleView = titleView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch (segue.identifier!) {
            case "goToSetList":
                let destVC:SetsViewController = segue.destination as! SetsViewController
                let indexPath = self.tableView.indexPathForSelectedRow!
                let keys:[String] = (self.sets!.dictionaryObject!.keys.map { (key:String) -> String in
                    return key
                })
                
                let key = keys[indexPath.row]
                destVC.sets = self.sets![key]
                destVC.title = key
                break
            case "showDownloadedSets":
                let destVC:SetsViewController = segue.destination as! SetsViewController
                destVC.downloadedSets = SetsHelper.getDownloadedSets()
                break
            case "goToDownloading":
                let destVC:SetsViewController = segue.destination as! SetsViewController
                destVC.downloadedSets = SetsHelper.getDownloadingSets()
                break
            default: break
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (self.downloadedSets != nil) {
            return 1
        }
        
        return (self.sets?["_sets"] != nil) ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.downloadedSets != nil) {
            return self.downloadedSets?.count ?? 0
        }
        
        if (self.sets == nil) {
            return 0;
        }
        
        var count = 0
        if (section == 0) {
            let sets = self.sets?.dictionaryObject?.keys.map { (key:String) -> String in
                return key
            }
            count = sets?.count ?? 0
            count -= (self.sets?.dictionaryObject?["_sets"] != nil) ? 1 : 0
        } else if (section == 1) {
            return self.sets?["_sets"].count ?? 0
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        var cell:RSSetTableViewCell = tableView.dequeueReusableCell(withIdentifier: "setTitleCell") as! RSSetTableViewCell
        if (self.downloadedSets != nil) {
            cell = self.getLocalSetCell(indexPath, cell:cell)
        } else if (self.sets != nil) {
            cell = self.getRemoteSetCell(indexPath, cell:cell)
        }
        
        return cell
    }
    
    func getLocalSetCell(_ indexPath:IndexPath, cell:RSSetTableViewCell) -> RSSetTableViewCell {
        
        cell.progressBarSize.constant = self.view.frame.size.width
        
        cell.cellType = .mediaFile
            
        let bassdriveSet = self.downloadedSets![indexPath.row]
        cell.bassdriveSetTitleLabel.text = bassdriveSet.bassdriveSetTitle
        cell.downloaded.alpha = 1
        cell.bassdriveSet = bassdriveSet
        cell.previouslyListened.alpha = bassdriveSet.hasPreviouslyListened() ? 1 : 0
        cell.downloadTask = RSDownloadManager.sharedManager.jobForBassdriveSet(bassdriveSet)
        
        return cell
    }
    
    func getRemoteSetCell(_ indexPath:IndexPath, cell:RSSetTableViewCell) -> RSSetTableViewCell {
        
        cell.progressBarSize.constant = self.view.frame.size.width
        
        if (indexPath.section == 0) {
            let keys:[String] = (self.sets?.dictionaryObject?.keys.map { (key:String) -> String in
                return key
            })!
            var row = indexPath.row
            
            var key:String = keys[row]
            while (key == "_sets") {
                key = keys[row++]
            }
            
            cell.bassdriveSetTitleLabel.text = key
            cell.cellType = .folder
        } else if (indexPath.section == 1) {
            cell.cellType = .mediaFile
            
            if let setDict = self.sets?["_sets"].arrayObject![indexPath.row] as? Dictionary<String, String> {
                let bassdriveSet = BassdriveSet(title:setDict["title"], url:URL(string: setDict["url"] as String!))
                cell.bassdriveSetTitleLabel.text = bassdriveSet.bassdriveSetTitle
                cell.downloaded.alpha = bassdriveSet.exists() ? 1 : 0
                cell.bassdriveSet = bassdriveSet
                if let downloadTask = RSDownloadManager.sharedManager.jobForBassdriveSet(bassdriveSet) {
                    cell.downloadTask = downloadTask
                }
                cell.previouslyListened.alpha = bassdriveSet.hasPreviouslyListened() ? 1 : 0
            }
            
        }
        return cell
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        
        if (identifier == "goToSetList") {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let cell:RSSetTableViewCell = tableView.cellForRow(at: indexPath) as! RSSetTableViewCell
                if (cell.cellType == .mediaFile) {
                    return false
                }
            }
        }
        
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell:RSSetTableViewCell = tableView.cellForRow(at: indexPath) as! RSSetTableViewCell
        
        if let bassdriveSet = cell.bassdriveSet {
            if (bassdriveSet.exists()) {
                RSPlaybackManager.sharedInstance.playSet(bassdriveSet)
            } else {
                cell.downloadTask = RSDownloadManager.sharedManager.enqueForDownload(bassdriveSet)
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        }
       
    }

}
