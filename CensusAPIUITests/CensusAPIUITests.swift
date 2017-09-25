//
//  CensusAPIUITests.swift
//  CensusAPIUITests
//
//  Created by Dean Copeland on 9/24/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import XCTest

class CensusAPIUITests: XCTestCase {
    
    var app: XCUIApplication!
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Average Travel Time To Work"]/*[[".cells.staticTexts[\"Average Travel Time To Work\"]",".staticTexts[\"Average Travel Time To Work\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.navigationBars["Average Travel Time To Work"].buttons["Graph It!"].tap()
        
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Settings"].tap()
        tablesQuery/*@START_MENU_TOKEN@*/.switches["Cubic Smoothing"]/*[[".cells.switches[\"Cubic Smoothing\"]",".switches[\"Cubic Smoothing\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tabBarsQuery.buttons["Help"].tap()
        tabBarsQuery.buttons["Chart"].tap()

        
    }
    
}
