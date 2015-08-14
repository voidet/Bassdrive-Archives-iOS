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
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        
        if let directoryContents =  NSFileManager.defaultManager().contentsOfDirectoryAtPath(documentsUrl.path!, error: nil) {
            for set in directoryContents {
                var bassdriveSet = BassdriveSet()
                bassdriveSet.bassdriveSetTitle = set.lastPathComponent
                bassdriveSet.bassdriveSetUrlString = set.lastPathComponent
                bassdriveSet.bassdriveSetUrlString = bassdriveSet.filePath()
                sets.append(bassdriveSet)
            }
        }
        
        return sets
    }

}
