//
//  SettingsViewViewModelTests.swift
//  CensusAPITests
//
//  Created by Dean Copeland on 10/13/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
import RxBlocking
@testable import CensusAPI

class SettingsViewModelTests: XCTestCase {
    
    var viewModel: SettingsViewModel!
    var scheduler: ConcurrentDispatchQueueScheduler!
    
    override func setUp() {
        super.setUp()
        
        viewModel = SettingsViewModel()
        scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
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
        
        let lineWidthStringObservable = viewModel.chartLineWidthStringDriver
        .asObservable()
        .subscribeOn(scheduler)
        
        viewModel.chartLineWidthObserver.onNext(3.13)

        XCTAssertEqual(try! lineWidthStringObservable.toBlocking().first()!, "3.1")
    }
    

    
}
