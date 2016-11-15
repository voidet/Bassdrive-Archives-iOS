//
//  BassdriveTests.swift
//  BassdriveTests
//
//  Created by Richard Sbresny on 7/25/15.
//  Copyright (c) 2015 Richard Sbresny. All rights reserved.
//

import UIKit
import XCTest

class BassdriveSetTests: XCTestCase {

    func testBassdriveSetNameSettingFromURL() {
        
        let title = "mewmew this is awesome.mp3"
        let url = URL(string: "http://www.bassdrive.com/this/is/an/mewmew%20this%20is%20awesome.mp3")
        
        var set = BassdriveSet(title: title, url:nil)
        XCTAssert(set.bassdriveSetTitle == "mewmew this is awesome", "Pass")
        XCTAssertFalse(set.bassdriveSetTitle == "mewmew this is awesome.mp3", "Pass")
        
        set = BassdriveSet(title: nil, url: url)
        XCTAssert(set.bassdriveSetTitle == "mewmew this is awesome", "Pass")
        XCTAssertFalse(set.bassdriveSetTitle == "mewmew this is awesome.mp3", "Pass")
        
        set = BassdriveSet(title: title, url: url)
        XCTAssert(set.bassdriveSetTitle == "mewmew this is awesome", "Pass")
        XCTAssertFalse(set.bassdriveSetTitle == "mewmew this is awesome.mp3", "Pass")
        
        set = BassdriveSet(title: nil, url: nil)
        XCTAssertFalse(set.bassdriveSetTitle == "mewmew this is awesome", "Pass")
        XCTAssertFalse(set.bassdriveSetTitle == "mewmew this is awesome.mp3", "Pass")
        
    }
    
    func testBassdriveSetExists() {
        
        let path:String! = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        let file:String = "\(path)/voidet.mp3"
        
        do {
            try! FileManager().removeItem(atPath: file)
        }
        
        var set = BassdriveSet(title: "voidet", url: URL(string: "voidet.mp3"))
        XCTAssertFalse(set.exists(), "Pass")
        
        try! "test".write(toFile: file, atomically: false, encoding: String.Encoding.utf8)

        XCTAssert(set.exists(), "Pass")
        
        set = BassdriveSet(title: nil, url: nil)
        XCTAssertFalse(set.exists(), "Pass")
    }
    
    func testHasPreviouslyListened() {

        UserDefaults.standard.removeObject(forKey: "mew.mp3")
        var set = BassdriveSet(title: nil, url: nil)
        XCTAssertFalse(set.hasPreviouslyListened(), "Pass")
        
        set = BassdriveSet(title: "mew", url: URL(string: "mew.mp3"))
        
        XCTAssertFalse(set.hasPreviouslyListened(), "Pass")
        
        UserDefaults.standard.set(true, forKey: "mew.mp3")
        UserDefaults.standard.synchronize()
        
        XCTAssert(set.hasPreviouslyListened(), "Pass")
    }
    
}
