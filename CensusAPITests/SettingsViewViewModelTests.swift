//
//  SettingsViewViewModelTests.swift
//  CensusAPITests
//
//  Created by Dean Copeland on 10/13/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import XCTest
@testable import CensusAPI

class SettingsViewViewModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    func testLineWidthFloat() {
        let viewModel = SettingsViewModel()
        UserDefaults.setChartLineWidth(3.14)
        XCTAssertEqual(viewModel.chartLineWidthFloat, 3.14)
    }
    
    func testLineWidthString() {
        let viewModel = SettingsViewModel()
        UserDefaults.setChartLineWidth(3.13)
        XCTAssertEqual(viewModel.chartLineWidthString, "3.1")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
