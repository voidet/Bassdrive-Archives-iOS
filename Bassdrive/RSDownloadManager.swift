//
//  RSDownloadManager.swift
//  Bassdrive
//
//  Created by Richard Sbresny on 7/25/15.
//  Copyright (c) 2015 Richard Sbresny. All rights reserved.
//

import UIKit

class RSDownloadManager {
    
    private var downloadQueue:[DownloadTask] = []
    static let sharedManager = RSDownloadManager()
    private var isExecuting:Bool = false
    private var activeDownloadCount:Int = 0
    
    private init() {}
    
    func enqueForDownload(bassdriveSet:BassdriveSet) {
        var downloadTask = DownloadTask()
        downloadTask.requestUrlString = bassdriveSet.bassdriveSetUrlString
        self.addAndEnqueue(downloadTask)
    }
    
    func jobForBassdriveSet(bassdriveSet:BassdriveSet) -> DownloadTask {
        return DownloadTask()
    }
    
    private func addAndEnqueue(downloadTask:DownloadTask) {
        self.downloadQueue.append(downloadTask)
        if (!self.isExecuting) {
            self.executeQueue()
        }
    }
    
    private func executeQueue() {
        
        if (self.activeDownloadCount < 3) {
            
            let toDownload = min(self.downloadQueue.count, 3 - self.activeDownloadCount)
            
            (toDownload).times {
                for task in self.downloadQueue {
                    if (!task.isActive) {
                        self.activeDownloadCount++
                        task.isActive = true
                        break;
                    }
                }
            }
            
        }
        
        
    }
   
}