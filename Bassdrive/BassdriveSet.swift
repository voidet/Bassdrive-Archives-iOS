//
//  BassdriveSet.swift
//  Bassdrive
//
//  Created by Richard Sbresny on 7/26/15.
//  Copyright (c) 2015 Richard Sbresny. All rights reserved.
//

import Foundation

class BassdriveSet {
    
    var bassdriveSetUrlString:String?
    var bassdriveSetTitle:String?
    
    convenience init(dict:Dictionary<String, String>) {
        self.init()
        self.bassdriveSetTitle = dict["title"]
        self.bassdriveSetUrlString = dict["url"]
    }
   
    func exists() -> Bool {
        let checkValidation = NSFileManager.defaultManager()
        return checkValidation.fileExistsAtPath(self.filePath().absoluteString)
    }
    
    func filePath() -> NSURL {
        let path:String! = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first
        let setPath = NSURL(string:path)!.URLByAppendingPathComponent(self.fileName()! as String)
        return setPath
    }
    
    func fileName() -> String? {
        return (NSURL(string:self.bassdriveSetUrlString!)!.lastPathComponent!).stringByRemovingPercentEncoding
    }
    
    func hasPreviouslyListened() -> Bool {
        if (self.bassdriveSetUrlString != nil &&
            NSUserDefaults.standardUserDefaults().objectForKey(self.bassdriveSetUrlString!) != nil) {
            return true
        }
        return false
    }
    
}
