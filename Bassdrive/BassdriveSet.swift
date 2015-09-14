//
//  BassdriveSet.swift
//  Bassdrive
//
//  Created by Richard Sbresny on 7/26/15.
//  Copyright (c) 2015 Richard Sbresny. All rights reserved.
//

import Foundation

struct BassdriveSet {
    
    private(set) var bassdriveSetTitle:String?
    private(set) var bassdriveSetURL:NSURL?
    
    init(title:String?, url:NSURL?) {
        let setTitle:String? = title ?? urlStringToFilename(url)
        bassdriveSetTitle = cleanMP3String(setTitle)
        bassdriveSetURL = url ?? filePath(setTitle)
    }

    func exists() -> Bool {
        let checkValidation = NSFileManager.defaultManager()
        if let path = self.filePath(bassdriveSetURL?.lastPathComponent)?.absoluteString.stringByRemovingPercentEncoding where self.filePath(bassdriveSetURL?.lastPathComponent) != nil {
            return checkValidation.fileExistsAtPath(path)
        }
        return false
    }
    
    func filePath(setTitle:String?) -> NSURL? {
        if (setTitle == nil) {
            return nil
        }
        
        let path:String! = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first
        let setPath = NSURL(string:path)!.URLByAppendingPathComponent(setTitle! as String)
        return setPath
    }
    
    func hasPreviouslyListened() -> Bool {
        if let setURL = bassdriveSetURL {
            return NSUserDefaults.standardUserDefaults().objectForKey(setURL.absoluteString) != nil
        }
        return false
    }
    
    private func urlStringToFilename(urlInput:NSURL?) -> String? {
        if let url = urlInput {
            return url.lastPathComponent!.stringByRemovingPercentEncoding!
        }
        return nil
    }
    
    private func cleanMP3String(inputString:String?) -> String? {
        if (inputString == nil) {
            return nil
        }
        return inputString!.replace("\\.mp3", template: "")
    }
    
}