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
    
    private var totalFileSize:Int64 = 0
    private var totalDownloaded:Int64 = 0 {
        didSet {
            if (self.totalFileSize > 0) {
                self.percentageCompleted = Double(self.totalDownloaded) / Double(self.totalFileSize) * 100
            }
        }
    }
    private var percentageCompleted:Double = 0 {
        didSet {
            if let monitor = progressMonitor {
                monitor(percentageCompleted)
            }
        }
    }
    private var completion:[(DownloadTask, Bool) -> ()] = []
    private var activeRequest:Request?
    
    func addCompletion(task:@escaping (DownloadTask, Bool) -> ()) {
        completion.append(task)
    }
    
    private func beginDownload() {
        
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        
        self.activeRequest = Alamofire.download(self.requestUrl!.absoluteString, to: destination).downloadProgress { progress in
            self.totalDownloaded = progress.completedUnitCount
            self.totalFileSize = progress.totalUnitCount
            return
        }.responseData { response in
            for downloadCompletion:(DownloadTask, Bool) -> () in self.completion {
                downloadCompletion(self, response.result.error == nil)
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
