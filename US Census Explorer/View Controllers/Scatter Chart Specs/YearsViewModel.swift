//
//  YearsViewModel.swift
//  CensusAPI
//
//  Created by Dean Copeland on 1/17/18.
//  Copyright © 2018 Dean Copeland. All rights reserved.
//

import RxSwift
import RxCocoa

class YearsViewModel {
    
    private let disposeBag = DisposeBag()
    
    private let chartSpecs: ChartSpecs
    
    var yearsDataSource: YearsDataSource!
    
    private let _alertMessage = PublishSubject<String>()
    
    // MARK: - Inputs
    let chooseYear: AnyObserver<Int16>
    
    // MARK: - Outputs
    let alertMessage: Observable<String>
    let didChooseYear: Observable<Int16>
    
    init(chartSpecs: ChartSpecs) {
        
        self.chartSpecs = chartSpecs
        
        yearsDataSource = YearsDataSource(currentlySelectedYear: chartSpecs.year.value)
        
        self.alertMessage = _alertMessage.asObservable()
        
        let _chooseYear = PublishSubject<Int16>()
        self.chooseYear = _chooseYear.asObserver()
        self.didChooseYear = _chooseYear.asObservable()
        
    }
    
    public func yearAtIndexPath(_ indexPath: IndexPath) -> Int16 {
        return yearsDataSource.getYear(at: indexPath)
    }
    
}
