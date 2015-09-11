//
//  DownloadTask.swift
//  Bassdrive
//
//  Created by Richard Sbresny on 7/25/15.
//  Copyright (c) 2015 Richard Sbresny. All rights reserved.
//

import UIKit
import Alamofire

class DownloadTask {
    
    var requestUrlString:String?
    var mediaObject:AnyObject?
    var isActive:Bool = false {
        willSet {
            if (!self.isActive) {
                self.beginDownload()
            }
        }
    }
    var totalFileSize:Int64 = 0
    var totalDownloaded:Int64 = 0 {
        didSet {
            if (self.totalFileSize > 0) {
                self.percentageCompleted = Double(self.totalDownloaded) / Double(self.totalFileSize) * 100
            }
        }
    }
    var percentageCompleted:Double = 0 {
        didSet {
            if let monitor = self.progressMonitor {
                monitor(self.percentageCompleted)
            }
        }
    }
    var progressMonitor:((Double) -> (Void))?
    var completion:((Void) -> (Void))?
    
    private var activeRequest:Request?
    
    private func beginDownload() {
        
        let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
        
        self.activeRequest = Alamofire.download(.GET, self.requestUrlString!, destination: destination).progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
            self.totalDownloaded = totalBytesRead
            self.totalFileSize = totalBytesExpectedToRead
            return
        }.response { (request, response, data, error) -> Void in
            if let completion = self.completion {
                completion()
            }
        }
    }
    
    func cancelDownload() {
        self.activeRequest?.cancel()
    }
   
}