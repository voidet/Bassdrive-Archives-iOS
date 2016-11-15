//
//  RSPlayerViewController.swift
//  
//
//  Created by Richard S on 2/08/2015.
//
//

import UIKit
import RxSwift
import RxCocoa

class RSPlayerViewController: UIViewController, RSPlaybackManagerProtocol {

    @IBOutlet var playbackProgressBarXOffset:NSLayoutConstraint!
    @IBOutlet var playbackProgressBar:UIView!
    @IBOutlet var timeLabel:UILabel!
    @IBOutlet var playPauseButton:UIButton!
    @IBOutlet var playbackHead:UIView!
    
    fileprivate var scrubbing:Bool = false
    fileprivate var playbackHeadCurrentPosition:CGPoint = CGPoint.zero
    fileprivate var initialLayout:Bool = false
    fileprivate var initialProgressSize:CGFloat?
    fileprivate var isCountingDown:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RSPlaybackManager.sharedInstance.addSubscriber(self)
        
//        NotificationCenter.default.notification("AVAudioSessionRouteChangeNotification", object:nil)
//            .map { notif in
//                self.pause()
//        }
    }
    
    override func viewDidLayoutSubviews() {
        if (!self.initialLayout) {
            self.initialLayout = true
            self.initialProgressSize = self.playbackProgressBar.frame.size.width
            self.playbackProgressBarXOffset.constant = self.initialProgressSize!
            self.playbackProgressBar.updateConstraints()
        }
    }
    
    func didUpdateToTime(_ time:TimeInterval) {
        self.updateProgress()
    }
    
    func updateProgress() {
        if (RSPlaybackManager.sharedInstance.isPlaying() && !self.scrubbing) {
            let totalTime = RSPlaybackManager.sharedInstance.totalTime()
            let currentTime = RSPlaybackManager.sharedInstance.currentTime()
            
            self.playbackProgressBarXOffset.constant = self.initialProgressSize! - (self.initialProgressSize! * CGFloat(currentTime / totalTime));
            self.timeLabel.text = self.isCountingDown ? self.stringFromTimeInterval(totalTime - currentTime) : self.stringFromTimeInterval(currentTime)
            self.view.layoutIfNeeded()
        }
    }
    
    fileprivate func stringFromTimeInterval(_ interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    fileprivate func updateTimeByPercentage(_ percentage:Double) {
        RSPlaybackManager.sharedInstance.jumpToTime(self.timeAtPercentage(percentage))
    }
    
    fileprivate func timeAtPercentage(_ difference:Double) -> TimeInterval {
        return TimeInterval(RSPlaybackManager.sharedInstance.totalTime()) * (difference / 100)
    }
    
    fileprivate func pause() {
        RSPlaybackManager.sharedInstance.pause()
    }
    
    @IBAction func playPause() {
        if (RSPlaybackManager.sharedInstance.isPlaying()) {
            RSPlaybackManager.sharedInstance.pause()
        } else {
            RSPlaybackManager.sharedInstance.play()
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.playPauseButton.alpha = 0
        }, completion: { (completed) in
            if (completed) {
                let imageString = RSPlaybackManager.sharedInstance.isPlaying() ? "Pause-50" : "Play-50"
                self.playPauseButton .setImage(UIImage(named: imageString), for:UIControlState())
                UIView.animate(withDuration: 0.2, animations: { () -> Void in
                  self.playPauseButton.alpha = 1
                })
            }
        })
        
    }
    
    @IBAction func changeCountDown() {
        UIView.animate(withDuration: 0.2, animations: {
            self.timeLabel.alpha = 0
        }, completion: { (completed) in
            self.isCountingDown = !self.isCountingDown
            self.updateProgress()
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.timeLabel.alpha = 1
            })
        })
    }
    
    @IBAction func handlePan(_ gestureRecogniser:UIPanGestureRecognizer) {
        if (gestureRecogniser.state == .began) {
            self.playbackHeadCurrentPosition = self.playbackHead.frame.origin
            self.scrubbing = true
        }
        
        let translation:CGPoint = gestureRecogniser.translation(in: self.playbackHead.superview!)
        
        var xOffset = translation.x + self.playbackHeadCurrentPosition.x + 5
        if (xOffset < self.playbackProgressBar.frame.origin.x) {
            xOffset = self.playbackProgressBar.frame.origin.x
        } else if (xOffset >= self.initialProgressSize! + self.playbackProgressBar.frame.origin.x + 5) {
            xOffset = self.playbackProgressBar.frame.origin.x + self.initialProgressSize! + 5
        }
        
        self.playbackHead.center = CGPoint(x: xOffset, y: self.playbackHead.center.y)

        let progressPosition = (self.playbackHead.center.x - self.playbackProgressBar.frame.origin.x)
        self.playbackProgressBarXOffset.constant = self.initialProgressSize! - progressPosition
        
        var difference = (progressPosition) / self.initialProgressSize!
        if (difference > 1) {
            difference = 1
        }
        
        self.timeLabel.text = self.stringFromTimeInterval(self.timeAtPercentage(Double(difference * 100)))

        if (gestureRecogniser.state == .ended) {
            self.updateTimeByPercentage(Double(difference * 100))
            self.scrubbing = false
        }
    }

}
