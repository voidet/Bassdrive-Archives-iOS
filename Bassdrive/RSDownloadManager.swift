//
//  RSDownloadManager.swift
//  Bassdrive
//
//  Created by Richard Sbresny on 7/25/15.
//  Copyright (c) 2015 Richard Sbresny. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RSDownloadManager {
    
    fileprivate(set) var downloadQueue:[DownloadTask] = []
    static let sharedManager = RSDownloadManager()
    fileprivate(set) var isExecuting:Bool = false
    fileprivate var activeDownloadCount:Int = 0
    
    fileprivate init() {}
    
    func enqueForDownload(_ bassdriveSet:BassdriveSet) -> DownloadTask {
        let downloadTask = DownloadTask()
        downloadTask.mediaObject = bassdriveSet
        downloadTask.requestUrl = bassdriveSet.bassdriveSetURL
        downloadTask.addCompletion(self.downloadCompleted)
        
        // only enque if not already downloading
        if (!self.jobIsActive(downloadTask)) {
            self.addAndEnqueue(downloadTask)
        }
        return downloadTask
    }
    
    func jobForBassdriveSet(_ bassdriveSet:BassdriveSet) -> DownloadTask? {
        return downloadQueue.lazy.filter({ $0.requestUrl == bassdriveSet.bassdriveSetURL }).first
    }
    
    fileprivate func addAndEnqueue(_ downloadTask:DownloadTask) {
        self.downloadQueue.append(downloadTask)
        if (!self.isExecuting) {
            self.executeQueue()
        }
    }
    
    fileprivate func jobIsActive(_ downloadTask:DownloadTask) -> Bool {
        
        for existingDownloadTask in self.downloadQueue {
            if (existingDownloadTask == downloadTask) {
                return true
            }
        }
        return false
    }
    
    fileprivate func executeQueue() {
        self.isExecuting = true
        if (self.activeDownloadCount < 3) {
            
            let toDownload = min(self.downloadQueue.count, 3 - self.activeDownloadCount)
            
            (toDownload).times {
                for task in self.downloadQueue {
                    if (!task.isActive) {
                        self.activeDownloadCount += 1
                        task.isActive = true
                        break;
                    }
                }
            }
            
        }
    }
    
    fileprivate func downloadCompleted(_ downloadTask:DownloadTask, success:Bool) {
        if let index = self.downloadQueue.index(of: downloadTask) {
            self.downloadQueue.remove(at: index)
        }
        
        self.activeDownloadCount -= 1
    }
   
}
