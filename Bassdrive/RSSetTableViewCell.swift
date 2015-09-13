//
//  RSSetTableViewCell.swift
//  Bassdrive
//
//  Created by Richard Sbresny on 7/25/15.
//  Copyright (c) 2015 Richard Sbresny. All rights reserved.
//

import UIKit

public enum Type :Int {
    case Folder
    case MediaFile
}

class RSSetTableViewCell: UITableViewCell {

    @IBOutlet var bassdriveSetTitleLabel:UILabel!
    @IBOutlet var bassdriveSetImageView:UIImageView!
    @IBOutlet var progressBar:UIView!
    @IBOutlet var progressBarSize:NSLayoutConstraint!
    @IBOutlet var selectedBackground:UIView!
    @IBOutlet var downloaded:UIView!
    @IBOutlet var previouslyListened:UIView!
    
    var bassdriveSetUrlString:String?
    var bassdriveSet:BassdriveSet?
    var cellType:Type?
    var downloadTask:DownloadTask? {
        didSet {
            if downloadTask == nil {
                return
            }
            
            self.downloadTask!.progressMonitor = updateProgress
            self.downloadTask!.addCompletion(completed)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutMargins = UIEdgeInsetsZero
        self.prepareForReuse()
        self.selectedBackground.alpha = 0
        self.downloaded.alpha = 0
        self.previouslyListened.alpha = 0
        self.previouslyListened.layer.cornerRadius = 6
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.bassdriveSetTitleLabel.text = ""
        self.backgroundColor = UIColor.whiteColor()
        self.progressBarSize.constant = self.frame.size.width
        self.previouslyListened.alpha = 0
    }
    
    private func updateProgress(progress:Double) {
        dispatch_async(dispatch_get_main_queue(), {
            self.progressBar.alpha = 1
            let width = self.frame.size.width
            let constant = width - CGFloat(width * (CGFloat(progress) / 100))
            self.progressBarSize.constant = constant
            self.layoutIfNeeded()
        })
    }
    
    private func completed(downloadTask:DownloadTask, success:Bool) {
        if (self.bassdriveSet!.exists()) {
            UIView.animateWithDuration(0.5, animations: {
                self.downloaded.alpha = 1
                self.progressBar.alpha = 0
            })
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        UIView .animateWithDuration(0.25, animations: {
            if (selected) {
                self.selectedBackground.alpha = 1;
            } else {
                self.selectedBackground.alpha = 0;
            }
        })
    }

    
}
