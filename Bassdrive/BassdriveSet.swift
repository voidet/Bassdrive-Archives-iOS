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
    private(set) var bassdriveSetURL:URL?
    
    init(title:String?, url:URL?) {
        let setTitle:String? = title ?? urlStringToFilename(urlInput: url)
        bassdriveSetTitle = cleanMP3String(inputString: setTitle)
        bassdriveSetURL = url ?? filePath(setTitle: setTitle)
    }

    func exists() -> Bool {
        let checkValidation = FileManager.default
        if let path = self.filePath(setTitle: bassdriveSetURL?.lastPathComponent)?.absoluteString.removingPercentEncoding, self.filePath(setTitle: bassdriveSetURL?.lastPathComponent) != nil {
            return checkValidation.fileExists(atPath: path)
        }
        return false
    }
    
    func filePath(setTitle:String?) -> URL? {
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
    
    private func urlStringToFilename(urlInput:URL?) -> String? {
        if let url = urlInput {
            return url.lastPathComponent.removingPercentEncoding!
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
