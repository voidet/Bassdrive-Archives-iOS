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
    func didUpdateToTime(_ time:TimeInterval)
}

class RSPlaybackManager : NSObject {
    
    static let sharedInstance = RSPlaybackManager()
    fileprivate var audioPlayer:AVAudioPlayer?
    fileprivate(set) var currentSet:BassdriveSet?
    fileprivate var playing:Bool = false
    fileprivate var progressTracker:Timer?
    fileprivate var delegates:[RSPlaybackManagerProtocol] = []
    
    override fileprivate init() {}
    
    func playSet(_ bassdriveSet:BassdriveSet) {
        self.currentSet = bassdriveSet

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            self.progressTracker = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(RSPlaybackManager.announceTime), userInfo: nil, repeats: true)
            self.progressTracker!.fire()
            
            let setTitle = self.currentSet!.bassdriveSetTitle
            if let filePath = self.currentSet!.filePath(setTitle)!.absoluteString as String? {
                self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath:filePath, isDirectory: false))
                self.audioPlayer!.prepareToPlay()
                self.play()
            }

        } catch {
            print("could not spin up AVAudioSession")
            return
        }
        
    }
    
    func addSubscriber(_ subscriber:RSPlaybackManagerProtocol) {
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
    
    fileprivate func updateMeta() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
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
                UserDefaults.standard.set(true, forKey: bassDriveSetURL)
                UserDefaults.standard.synchronize()
            }
        }
        
        for delegate in self.delegates {
            delegate.didUpdateToTime(self.currentTime())
        }
    }
    
    func currentTime() -> TimeInterval {
        return self.audioPlayer?.currentTime ?? 0
    }
    
    func totalTime() -> TimeInterval {
        return self.audioPlayer?.duration ?? 0
    }
    
    func isPlaying() -> Bool {
        return self.playing
    }
    
    func jumpToTime(_ time:TimeInterval) {
        self.audioPlayer?.currentTime = time
    }
    
   
}
