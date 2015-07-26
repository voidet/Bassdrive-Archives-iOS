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

    override func prepareForReuse() {
        self.bassdriveSetTitleLabel.text = ""
    }
    
}
