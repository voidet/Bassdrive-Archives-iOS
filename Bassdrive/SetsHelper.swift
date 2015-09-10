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
                let setURL = NSURL(string: set)!
                let bassdriveSet = BassdriveSet()
                bassdriveSet.bassdriveSetTitle = setURL.lastPathComponent
                bassdriveSet.bassdriveSetUrlString = setURL.lastPathComponent
                bassdriveSet.bassdriveSetUrlString = bassdriveSet.filePath()
                sets.append(bassdriveSet)
            }
        } catch {
            print("Could not find downloaded sets")
        }
        return sets
    }
    
}