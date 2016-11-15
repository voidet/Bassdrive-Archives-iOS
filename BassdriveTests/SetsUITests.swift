//
//  SetsUITests.swift
//  Bassdrive
//
//  Created by Richard Sbresny on 9/12/15.
//  Copyright © 2015 Richard Sbresny. All rights reserved.
//

import XCTest

class SetsUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
        let tablesQuery = XCUIApplication().tables
        
        XCTAssertEqual(tablesQuery.count, 1)
        XCTAssertEqual(tablesQuery.cells.count, 10)

        tablesQuery.staticTexts["Friday"].tap()
        tablesQuery.staticTexts["Urban Aristocracy - Citykings Matt D"].tap()
        tablesQuery.staticTexts["2012"].tap()
        XCTAssertGreaterThan(tablesQuery.cells.count, 1)
        
    }
    
    func testDownloadStartsAndAppears() {
        
        let tablesQuery = XCUIApplication().tables
        
        XCTAssertEqual(tablesQuery.count, 1)
        XCTAssertEqual(tablesQuery.cells.count, 10)
        
        tablesQuery.staticTexts["Friday"].tap()
        tablesQuery.staticTexts["Urban Aristocracy - Citykings Matt D"].tap()
        tablesQuery.staticTexts["2012"].tap()
        
        let cell = tablesQuery.cells.element(boundBy: 0)

//        cell.tap()
        let downloadingCell = cell.accessibilityValue
        print(downloadingCell)
        
        
        
    }
    
}
