//
//  BassdriveSet.swift
//  Bassdrive
//
//  Created by Richard Sbresny on 7/26/15.
//  Copyright (c) 2015 Richard Sbresny. All rights reserved.
//

import Foundation

struct BassdriveSet {
    
    fileprivate(set) var bassdriveSetTitle:String?
    fileprivate(set) var bassdriveSetURL:URL?
    
    init(title:String?, url:URL?) {
        let setTitle:String? = title ?? urlStringToFilename(url)
        bassdriveSetTitle = cleanMP3String(setTitle)
        bassdriveSetURL = url ?? filePath(setTitle)
    }

    func exists() -> Bool {
        let checkValidation = FileManager.default
        if let path = self.filePath(bassdriveSetURL?.lastPathComponent)?.absoluteString.stringByRemovingPercentEncoding, self.filePath(bassdriveSetURL?.lastPathComponent) != nil {
            return checkValidation.fileExists(atPath: path)
        }
        return false
    }
    
    func filePath(_ setTitle:String?) -> URL? {
        if (setTitle == nil) {
            return nil
        }
        
        let path:String! = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        let setPath = URL(string:path)!.appendingPathComponent(setTitle! as String)
        return setPath
    }
    
    func hasPreviouslyListened() -> Bool {
        if let setURL = bassdriveSetURL {
            return UserDefaults.standard.object(forKey: setURL.absoluteString) != nil
        }
        return false
    }
    
    fileprivate func urlStringToFilename(_ urlInput:URL?) -> String? {
        if let url = urlInput {
            return url.lastPathComponent.stringByRemovingPercentEncoding!
        }
        return nil
    }
    
    fileprivate func cleanMP3String(_ inputString:String?) -> String? {
        if (inputString == nil) {
            return nil
        }
        return inputString!.replace("\\.mp3", template: "")
    }
    
}
