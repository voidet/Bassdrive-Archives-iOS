//
//  DownloadTask.swift
//  Bassdrive
//
//  Created by Richard Sbresny on 7/25/15.
//  Copyright (c) 2015 Richard Sbresny. All rights reserved.
//

import UIKit
import Alamofire

class DownloadTask:Equatable {
    
    var requestUrl:URL?
    var mediaObject:Any?
    var isActive:Bool = false {
        willSet {
            if (!self.isActive) {
                self.beginDownload()
            }
        }
    }
    var progressMonitor:((Double) -> (Void))?
    
    fileprivate var totalFileSize:Int64 = 0
    fileprivate var totalDownloaded:Int64 = 0 {
        didSet {
            if (self.totalFileSize > 0) {
                self.percentageCompleted = Double(self.totalDownloaded) / Double(self.totalFileSize) * 100
            }
        }
    }
    fileprivate var percentageCompleted:Double = 0 {
        didSet {
            if let monitor = progressMonitor {
                monitor(percentageCompleted)
            }
        }
    }
    fileprivate var completion:[(DownloadTask, Bool) -> ()] = []
    fileprivate var activeRequest:Request?
    
    func addCompletion(_ task:@escaping (DownloadTask, Bool) -> ()) {
        completion.append(task)
    }
    
    fileprivate func beginDownload() {
        
        let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
        
        self.activeRequest = Alamofire.download(.GET, self.requestUrl!.absoluteString, destination: destination).progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
            self.totalDownloaded = totalBytesRead
            self.totalFileSize = totalBytesExpectedToRead
            return
        }.response { (request, response, data, error) -> Void in
            for downloadCompletion:(DownloadTask, Bool) -> () in self.completion {
                downloadCompletion(self, error == nil)
            }
            self.completion.removeAll()
            return
        }
    }
    
    func cancelDownload() {
        self.activeRequest?.cancel()
    }
   
}

func ==(lhs: DownloadTask, rhs: DownloadTask) -> Bool {
    return lhs.requestUrl == rhs.requestUrl
}
