//
//  CensusAPITests.swift
//  CensusAPITests
//
//  Created by Dean Copeland on 9/24/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import XCTest
@testable import CensusAPI

class CensusAPITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetAllFacts() {
        let ds = CensusDataSource()
        let allFacts = ds.getAllFacts()
        XCTAssertEqual(allFacts.count, 10, "10 facts were not returned")
    }
 
    func testDeleteAndReloadGeographies() {
        let ds = CensusDataSource()
        ds.deleteAllGeographies()
        let geographies = ds.getAllGeographies()
        XCTAssertEqual(geographies!.count, 0, "Geographies were not deleted")
        
        let promise = expectation(description: "Status code 200")
        ds.retrieveGeographies() { (success, error) in
            if success {
                promise.fulfill()
            } else {
                XCTFail("Error: Failed to get Geographies")
                return
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
        let geographies2 = ds.getAllGeographies()
        XCTAssertTrue(geographies2!.count > 0, "Geographies were not retrieved")
    }
    
    func testDeleteAndReloadCensusValues() {
        let ds = CensusDataSource()
        ds.deleteAllCensusValues()
        let values = ds.getAllCensusValues()
        XCTAssertEqual(values!.count, 0, "Census values were not deleted")
        
        let promise = expectation(description: "Status code 200")
        ds.retrieveAllCensusValues() { (success, error) in
            if success {
                promise.fulfill()
            } else {
                XCTFail("Error: Failed to get Census Values")
                return
            }
        }
        waitForExpectations(timeout: 10, handler: nil)
        let values2 = ds.getAllCensusValues()
        XCTAssertTrue(values2!.count > 0, "Census values were not retrieved")
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
