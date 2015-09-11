//
//  BassdriveSet.swift
//  Bassdrive
//
//  Created by Richard Sbresny on 7/26/15.
//  Copyright (c) 2015 Richard Sbresny. All rights reserved.
//

import Foundation

struct BassdriveSet {
    
    var bassdriveSetUrl:NSURL? {
        didSet(newValue) {
            self.bassdriveSetTitle = self.urlStringToFilename(newValue!)
        }
    }
    var bassdriveSetTitle:String? {
        didSet(newValue) {
            bassdriveSetTitle = self.cleanMP3String(newValue!)
            bassdriveSetUrl = self.filePath()
        }
    }
    
    init(setTitle:String) {
        self.bassdriveSetTitle = self.cleanMP3String(setTitle)
    }
    
    init(url:NSURL) {
        self.bassdriveSetUrl = url
    }
    
    init(dict:Dictionary<String, String>) {
        self.bassdriveSetTitle = dict["title"]
        self.bassdriveSetUrl = NSURL(string:dict["url"]!)
    }
   
    func exists() -> Bool {
        let checkValidation = NSFileManager.defaultManager()
        return checkValidation.fileExistsAtPath(self.filePath().absoluteString)
    }
    
    func filePath() -> NSURL {
        let path:String! = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first
        let setPath = NSURL(string:path)!.URLByAppendingPathComponent(self.bassdriveSetTitle! as String)
        return setPath
    }
    
    func hasPreviouslyListened() -> Bool {
        if (self.bassdriveSetUrl != nil &&
            NSUserDefaults.standardUserDefaults().objectForKey(self.bassdriveSetUrl!.absoluteString) != nil) {
            return true
        }
        return false
    }
    
    private func urlStringToFilename(urlInput:NSURL) -> String {
        return self.bassdriveSetUrl!.lastPathComponent!.stringByRemovingPercentEncoding!
    }
    
    private func cleanMP3String(inputString:String) -> String {
        return inputString.replace("\\.mp3", template: "")
    }
    
}