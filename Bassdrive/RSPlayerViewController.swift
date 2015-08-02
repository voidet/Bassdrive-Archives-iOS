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
        if (RSPlaybackManager.sharedInstance.isPlaying()) {
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

}
