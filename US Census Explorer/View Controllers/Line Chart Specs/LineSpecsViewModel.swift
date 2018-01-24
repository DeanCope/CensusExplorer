//
//  LineSpecsViewModel.swift
//  CensusAPI
//
//  Created by Dean Copeland on 12/17/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import RxSwift
import RxCocoa

class LineSpecsViewModel {
    
    private let disposeBag = DisposeBag()
    
    var factsDataSource = FactsDataSource()
    
    let headerCellSectionName = "Touch a topic to explore."
    
    // MARK: - Inputs
    let selectFact: AnyObserver<CensusFact>
    
    // MARK: - Outputs
    let didSelectFact: Observable<CensusFact>
    
    // MARK: -
    //RxSwift Private Variables
    private let _progressMessage = Variable<String?>(nil)
    private let _dataUpdated = Variable<Bool>(false)
    
    // RXSwift drivers
    var querying: Driver<Bool> { return CensusDataSource.sharedInstance.querying }
    var queryProgress: Driver<Float> { return CensusDataSource.sharedInstance.queryProgress }
    var progressMessage: Driver<String?> { return _progressMessage.asDriver() }
    var queryCompletion: Driver<(Bool,String?)> { return CensusDataSource.sharedInstance.queryCompletion }
    var dataUpdated: Driver<Bool> { return _dataUpdated.asDriver() }
        
    init() {
        
        let _selectFact = PublishSubject<CensusFact>()
        self.selectFact = _selectFact.asObserver()
        self.didSelectFact = _selectFact.asObservable()
        
        // Create a query progress message for display on the UI
        queryProgress
            .drive(onNext: { [weak self] progress in
                let percent = Int(progress * 100.0)
                self?._progressMessage.value = "Download: \(percent)%"
            })
            .disposed(by: disposeBag)
        
        // Determine when the data has been updated so the UI should reload the data
        queryCompletion
            .drive(onNext: { [weak self] completed, _ in
                if completed {
                    self?.factsDataSource.doFetch()
                    self?._dataUpdated.value = true
                }
            })
        .disposed(by: disposeBag)
    }
    
    public func factAtIndexPath(_ indexPath: IndexPath) -> CensusFact {
        return factsDataSource.getFact(at: indexPath)
    }
    
    public func reloadData() {
        CensusDataSource.sharedInstance.reloadData()
    }
    
    public func refreshGeosAndValues() {
        CensusDataSource.sharedInstance.refreshGeosAndValues()
    }
}
