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

class RSPlaybackManager {
    
    static let sharedInstance = RSPlaybackManager()
    var audioPlayer:AVAudioPlayer?
    
    private init() {}
    
    func playSet(bassdriveSet:BassdriveSet) {
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        
        var error:NSError?
        self.audioPlayer = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: bassdriveSet.filePath()!), error: &error)
        self.audioPlayer?.prepareToPlay()
        self.audioPlayer?.play()

        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [MPMediaItemPropertyTitle : bassdriveSet.fileName()!]
    }
   
}
