//
//  RSPlayerViewController.swift
//  
//
//  Created by Richard S on 2/08/2015.
//
//

import UIKit

class RSPlayerViewController: UIViewController {

    @IBOutlet var playbackProgressBarXOffset:NSLayoutConstraint!
    @IBOutlet var playbackProgressBar:UIView!
    @IBOutlet var timeLabel:UILabel!
    @IBOutlet var playPauseButton:UIButton!
    @IBOutlet var playbackHead:UIView!
    
    private var scrubbing:Bool = false
    private var playbackHeadCurrentPosition:CGPoint = CGPointZero
    private var initialLayout:Bool = false
    private var initialProgressSize:CGFloat?
    private var progressTracker:NSTimer?
    private var isCountingDown:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.progressTracker = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "updateProgress", userInfo: nil, repeats: true)
        self.progressTracker!.fire()
    }
    
    override func viewDidLayoutSubviews() {
        if (!self.initialLayout) {
            self.initialLayout = true
            self.initialProgressSize = self.playbackProgressBar.frame.size.width
            self.playbackProgressBarXOffset.constant = self.initialProgressSize!
            self.playbackProgressBar.updateConstraints()
        }
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
    
    private func stringFromTimeInterval(interval: NSTimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func updateTimeByPercentage(percentage:Double) {
        RSPlaybackManager.sharedInstance.jumpToTime(self.timeAtPercentage(percentage))
    }
    
    private func timeAtPercentage(difference:Double) -> NSTimeInterval {
        return NSTimeInterval(RSPlaybackManager.sharedInstance.totalTime()) * (difference / 100)
    }
    
    @IBAction func playPause() {
        if (RSPlaybackManager.sharedInstance.isPlaying()) {
            RSPlaybackManager.sharedInstance.pause()
        } else {
            RSPlaybackManager.sharedInstance.play()
        }
        
        UIView.animateWithDuration(0.2, animations: {
            self.playPauseButton.alpha = 0
        }, completion: { (completed) in
            if (completed) {
                let imageString = RSPlaybackManager.sharedInstance.isPlaying() ? "Pause-50" : "Play-50"
                self.playPauseButton .setImage(UIImage(named: imageString), forState:.Normal)
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                  self.playPauseButton.alpha = 1
                })
            }
        })
        
    }
    
    @IBAction func changeCountDown() {
        UIView.animateWithDuration(0.2, animations: {
            self.timeLabel.alpha = 0
        }, completion: { (completed) in
            self.isCountingDown = !self.isCountingDown
            self.updateProgress()
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.timeLabel.alpha = 1
            })
        })
    }
    
    @IBAction func handlePan(gestureRecogniser:UIPanGestureRecognizer) {
        if (gestureRecogniser.state == .Began) {
            self.playbackHeadCurrentPosition = self.playbackHead.frame.origin
            self.scrubbing = true
        }
        var translation:CGPoint = gestureRecogniser.translationInView(self.playbackHead.superview!)
        
        var xOffset = translation.x + self.playbackHeadCurrentPosition.x + 5
        if (xOffset < self.playbackProgressBar.frame.origin.x) {
            xOffset = self.playbackProgressBar.frame.origin.x
        } else if (xOffset >= self.initialProgressSize! + self.playbackProgressBar.frame.origin.x + 5) {
            xOffset = self.playbackProgressBar.frame.origin.x + self.playbackProgressBar.frame.size.width
        }
        
        self.playbackHead.center = CGPointMake(xOffset, self.playbackHead.center.y)

        let progressPosition = (self.playbackHead.center.x - self.playbackProgressBar.frame.origin.x)
        self.playbackProgressBarXOffset.constant = self.initialProgressSize! - progressPosition
        
        var difference = (progressPosition) / self.initialProgressSize!
        if (difference > 1) {
            difference = 1
        }
        
        self.timeLabel.text = self.stringFromTimeInterval(self.timeAtPercentage(Double(difference * 100)))

        if (gestureRecogniser.state == .Ended) {
            self.updateTimeByPercentage(Double(difference * 100))
            self.scrubbing = false
        }
    }

}
