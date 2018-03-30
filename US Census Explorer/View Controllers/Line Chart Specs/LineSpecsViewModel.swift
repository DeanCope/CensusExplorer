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
    
    private let censusDataSource: CensusDataSource!
    public let factsDataSource: FactsDataSource!
    
    let headerCellSectionName = "Touch a topic to explore."
    
    // MARK: - Inputs (From the UI)
    let selectFact: AnyObserver<CensusFact>
    let requestFactDetails: AnyObserver<CensusFact>
    let requestReloadData: AnyObserver<Void>
    
    // MARK: - Outputs (To UI and Coordinator)
    let alertMessage: Observable<(String,String)>
    let didSelectFact: Observable<CensusFact>
    let didRequestFactDetails: Observable<CensusFact>
    let didRequestReloadData: Observable<Void>
    
    // RXSwift drivers - Output to UI
    var querying: Driver<Bool> { return censusDataSource.querying }
    var queryProgress: Driver<Float> { return censusDataSource.queryProgress }
    var progressMessage: Driver<String?> { return _progressMessage.asDriver() }
    var queryCompletion: Driver<(Bool,String?,Bool)> { return censusDataSource.queryCompletion }
    var dataUpdated: Driver<Bool> { return _dataUpdated.asDriver() }
    
    // MARK: - RxSwift Private Variables
    private let _alertMessage = ReplaySubject<(String,String)>.create(bufferSize: 1)
    private let _progressMessage = Variable<String?>(nil)
    
    private let _dataUpdated = Variable<Bool>(false)
        
    init(dataSource: CensusDataSource) {
        self.censusDataSource = dataSource
        self.factsDataSource = FactsDataSource(dataSource: dataSource)
        
        self.alertMessage = _alertMessage.asObservable()
        
        let _selectFact = PublishSubject<CensusFact>()
        self.selectFact = _selectFact.asObserver()
        self.didSelectFact = _selectFact.asObservable()
        
        let _requestFactDetails = PublishSubject<CensusFact>()
        self.requestFactDetails = _requestFactDetails.asObserver()
        self.didRequestFactDetails = _requestFactDetails.asObservable()
        
        let _requestReloadData = PublishSubject<Void>()
        self.requestReloadData = _requestReloadData.asObserver()
        self.didRequestReloadData = _requestReloadData.asObservable()
        
        factsDataSource.alertMessage
            .bind(to: _alertMessage)
            .disposed(by: disposeBag)
 
        didRequestFactDetails
            .subscribe(onNext: { [weak self] fact in
                self?._alertMessage.onNext((fact.factName ?? "Unknown", fact.factDescription ?? "Unknown"))
            })
            .disposed(by: disposeBag)
        
        didRequestReloadData
            .subscribe(onNext: { [weak self] in
                self?.censusDataSource.reloadData()
            })
            .disposed(by: disposeBag)
        
        // Create a query progress message for display on the UI
        queryProgress
            .drive(onNext: { [weak self] progress in
                let percent = Int(progress * 100.0)
                self?._progressMessage.value = "Retrieving Data: \(percent)%"
            })
            .disposed(by: disposeBag)
        
        // Determine when the data has been updated so the UI should reload the data
        queryCompletion
            .drive(onNext: { [weak self] success, _, _ in
                if success {
                    self?.factsDataSource.doFetch()
                    self?._dataUpdated.value = true
                }
            })
        .disposed(by: disposeBag)
    }
    
    public func factAtIndexPath(_ indexPath: IndexPath) -> CensusFact {
        return factsDataSource.getFact(at: indexPath)
    }
    
    public func refreshGeosAndValues() {
        censusDataSource.refreshGeosAndValues(reload: false)
    }
}
