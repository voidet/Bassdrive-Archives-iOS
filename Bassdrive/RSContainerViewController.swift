//
//  RSContainerViewController.swift
//  Bassdrive
//
//  Created by Richard Sbresny on 8/2/15.
//  Copyright (c) 2015 Richard Sbresny. All rights reserved.
//

import UIKit

class RSContainerViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        switch event!.subtype {
            case .remoteControlPause:
                RSPlaybackManager.sharedInstance.pause()
                break
            case .remoteControlPlay:
                RSPlaybackManager.sharedInstance.play()
                break
            default:
                break
        }
    }

}
