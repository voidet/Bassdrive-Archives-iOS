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
    @IBOutlet var progressBarSize:NSLayoutConstraint!
    
    var bassdriveSetUrlString:String?
    var bassdriveSet:BassdriveSet?
    var cellType:Type?
    var downloadTask:DownloadTask? {
        didSet {
            downloadTask?.progressMonitor = updateProgress
        }
    }
    
    override func awakeFromNib() {
        self.layoutMargins = UIEdgeInsetsZero
    }

    override func prepareForReuse() {
        self.bassdriveSetTitleLabel.text = ""
        self.backgroundColor = UIColor.whiteColor()
    }
    
    private func updateProgress(progress:Double) {
        dispatch_async(dispatch_get_main_queue(), {
            let width = self.frame.size.width
            let constant = width - CGFloat(width * (CGFloat(progress) / 100))
            self.progressBarSize.constant = constant
            self.layoutIfNeeded()
        })
        
    }
    
}
