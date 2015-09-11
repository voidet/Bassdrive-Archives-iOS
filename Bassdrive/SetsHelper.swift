//
//  SetsHelper.swift
//  Bassdrive
//
//  Created by Richard Sbresny on 8/14/15.
//  Copyright (c) 2015 Richard Sbresny. All rights reserved.
//

import Foundation

class SetsHelper {
    
    static func getDownloadedSets() -> [BassdriveSet] {
        var sets:[BassdriveSet] = []
        
        do {
            let documentsUrl:NSURL! =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
            let directoryContents:[String] = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(documentsUrl.path!)
            for set:String in directoryContents {
                let bassdriveSet = BassdriveSet()
                bassdriveSet.bassdriveSetTitle = set
                bassdriveSet.bassdriveSetUrlString = set
                bassdriveSet.bassdriveSetUrlString = bassdriveSet.filePath().absoluteString
                sets.append(bassdriveSet)
            }
        } catch {
            print("Could not find downloaded sets")
        }
        return sets
    }
    
    static func getDownloadingSets() -> [BassdriveSet] {
        
        if !RSDownloadManager.sharedManager.isExecuting {
            return []
        }
        
        let sets:[BassdriveSet] = RSDownloadManager.sharedManager.downloadQueue.filter { (dl:DownloadTask) -> Bool in
            if dl.mediaObject is BassdriveSet {
                return true
            }
            return false
        }.map { (dlTask:DownloadTask) -> BassdriveSet in
            return dlTask.mediaObject as! BassdriveSet
        }
        
        return sets
    }
    
}