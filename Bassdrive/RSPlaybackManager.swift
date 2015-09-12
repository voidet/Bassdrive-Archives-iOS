//
//  RSPlaybackManager.swift
//  
//
//  Created by Richard S on 30/07/2015.
//
//

import UIKit
import AVFoundation
import MediaPlayer

protocol RSPlaybackManagerProtocol {
    func didUpdateToTime(time:NSTimeInterval)
}

class RSPlaybackManager : NSObject {
    
    static let sharedInstance = RSPlaybackManager()
    private var audioPlayer:AVAudioPlayer?
    private(set) var currentSet:BassdriveSet?
    private var playing:Bool = false
    private var progressTracker:NSTimer?
    private var delegates:[RSPlaybackManagerProtocol] = []
    
    override private init() {}
    
    func playSet(bassdriveSet:BassdriveSet) {
        self.currentSet = bassdriveSet

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            self.progressTracker = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "announceTime", userInfo: nil, repeats: true)
            self.progressTracker!.fire()
            
            let setTitle = self.currentSet!.bassdriveSetTitle
            if let filePath = self.currentSet!.filePath(setTitle)!.absoluteString as String? {
                self.audioPlayer = try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath:filePath, isDirectory: false))
                self.audioPlayer!.prepareToPlay()
                self.play()
            }

        } catch {
            print("could not spin up AVAudioSession")
            return
        }
        
    }
    
    func addSubscriber(subscriber:RSPlaybackManagerProtocol) {
//        if find(self.delegates, subscriber) {
            self.delegates.append(subscriber)
//        }
    }
    
    func play() {
        if (self.audioPlayer != nil) {
            self.playing = self.audioPlayer!.play()
            self.updateMeta()
        }
    }
    
    func pause() {
        if (self.audioPlayer != nil) {
            self.playing = false
            self.audioPlayer?.pause()
            self.updateMeta()
        }
    }
    
    private func updateMeta() {
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [
            MPMediaItemPropertyTitle : self.currentSet!.bassdriveSetTitle ?? "Bassdrive ",
            MPMediaItemPropertyPlaybackDuration: self.audioPlayer!.duration,
            MPNowPlayingInfoPropertyPlaybackRate: self.playing ? 1 : 0,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: self.audioPlayer!.currentTime
        ]
    }
    
    func announceTime() {
        let percentage = (self.currentTime() / self.totalTime())
        
        if (percentage * 100 > 80) {
            if let bassDriveSetURL = self.currentSet?.bassdriveSetURL?.absoluteString {
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: bassDriveSetURL)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
        
        for delegate in self.delegates {
            delegate.didUpdateToTime(self.currentTime())
        }
    }
    
    func currentTime() -> NSTimeInterval {
        return self.audioPlayer?.currentTime ?? 0
    }
    
    func totalTime() -> NSTimeInterval {
        return self.audioPlayer?.duration ?? 0
    }
    
    func isPlaying() -> Bool {
        return self.playing
    }
    
    func jumpToTime(time:NSTimeInterval) {
        self.audioPlayer?.currentTime = time
    }
    
   
}
