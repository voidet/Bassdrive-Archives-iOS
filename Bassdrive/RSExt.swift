//
//  RSExt.swift
//  Bassdrive
//
//  Created by Richard Sbresny on 7/26/15.
//  Copyright (c) 2015 Richard Sbresny. All rights reserved.
//

import Foundation

extension Int {
    
    func times(_ function: (Void) -> Void) {
        for (i in 0 ..< self) {
            function();
        }
    }
    
}
