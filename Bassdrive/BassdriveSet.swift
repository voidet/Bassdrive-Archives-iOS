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
    
    init(dict:Dictionary<String, String>) {
        self.bassdriveSetTitle = dict["title"]
        self.bassdriveSetUrlString = dict["url"]
    }
   
    func exists() -> Bool {
        var checkValidation = NSFileManager.defaultManager()
        return checkValidation.fileExistsAtPath(self.filePath()!)
    }
    
    func filePath() -> String? {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first as! String
        var setPath = paths.stringByAppendingPathComponent(self.fileName()! as String)
        return setPath
    }
    
    func fileName() -> String? {
        return self.bassdriveSetUrlString?.lastPathComponent.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
    }
    
    func hasPreviouslyListened() -> Bool {
        if (self.bassdriveSetUrlString != nil &&
            NSUserDefaults.standardUserDefaults().objectForKey(self.bassdriveSetUrlString!) != nil) {
            return true
        }
        return false
    }
    
}
