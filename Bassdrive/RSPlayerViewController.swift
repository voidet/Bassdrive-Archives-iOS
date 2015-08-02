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
    
    private var initialLayout:Bool = false
    private var initialProgressSize:CGFloat?
    private var progressTracker:NSTimer?
    private var isCountingDown:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.progressTracker = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "updateProgress", userInfo: nil, repeats: true)
        self.progressTracker!.fire()
    }
    
    
    
//    override func sub() {
//        super.updateViewConstraints()
//        self.initialProgressSize = self.playbackProgressBar.frame.size.width
////        self.playbackProgressBarXOffset.constant = self.initialProgressSize!;
//                println(self.playbackProgressBar.frame)
//    }
    
    override func viewDidLayoutSubviews() {
        if (!self.initialLayout) {
            self.initialLayout = true
            self.initialProgressSize = self.playbackProgressBar.frame.size.width
            self.playbackProgressBarXOffset.constant = self.initialProgressSize!
            self.playbackProgressBar.updateConstraints()
        }
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent) {
        switch event.subtype {
            case .RemoteControlPause:
                RSPlaybackManager.sharedInstance.pause()
                break
            case .RemoteControlPlay:
                RSPlaybackManager.sharedInstance.play()
                break
            default:
                break
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
    
    @IBAction func changeCountDown() {
        UIView.animateWithDuration(0.2, animations: {
            self.timeLabel.alpha = 0
        }) { (completed) in
            self.isCountingDown = !self.isCountingDown
            self.updateProgress()
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.timeLabel.alpha = 1
            })
        }
    }

}
