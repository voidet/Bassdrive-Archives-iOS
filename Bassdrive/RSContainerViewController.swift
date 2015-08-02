//
//  RSContainerViewController.swift
//  Bassdrive
//
//  Created by Richard Sbresny on 8/2/15.
//  Copyright (c) 2015 Richard Sbresny. All rights reserved.
//

import UIKit

class RSContainerViewController: UIViewController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
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

}