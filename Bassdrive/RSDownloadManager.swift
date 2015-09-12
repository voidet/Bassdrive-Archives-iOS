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
    
    private(set) var downloadQueue:[DownloadTask] = []
    static let sharedManager = RSDownloadManager()
    private(set) var isExecuting:Bool = false
    private var activeDownloadCount:Int = 0
    
    private init() {}
    
    func enqueForDownload(bassdriveSet:BassdriveSet) -> DownloadTask {
        let downloadTask = DownloadTask()
        downloadTask.mediaObject = bassdriveSet
        downloadTask.requestUrl = bassdriveSet.bassdriveSetURL
        downloadTask.completion = self.downloadCompleted
        self.addAndEnqueue(downloadTask)
        return downloadTask
    }
    
    func jobForBassdriveSet(bassdriveSet:BassdriveSet) -> DownloadTask? {
        return downloadQueue.lazy.filter({ $0.requestUrl == bassdriveSet.bassdriveSetURL }).first
        
//        for downloadTask in self.downloadQueue {
//            if (bassdriveSet.bassdriveSetUrl == downloadTask.requestUrl) {
//                return downloadTask
//            }
//        }
//        return nil
    }
    
    private func addAndEnqueue(downloadTask:DownloadTask) {
        self.downloadQueue.append(downloadTask)
        if (!self.isExecuting) {
            self.executeQueue()
        }
    }
    
    private func executeQueue() {
        self.isExecuting = true
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
    
    private func downloadCompleted(downloadTask:DownloadTask, success:Bool) {
//        self.downloadQueue.remove(downloadTask)
        self.activeDownloadCount--
    }
   
}