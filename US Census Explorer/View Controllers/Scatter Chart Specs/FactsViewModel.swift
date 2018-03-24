//
//  FactsViewModel.swift
//  CensusAPI
//
//  Created by Dean Copeland on 1/15/18.
//  Copyright © 2018 Dean Copeland. All rights reserved.
//

import RxSwift
import RxCocoa

class FactsViewModel {
    
    private let disposeBag = DisposeBag()
    
    //var factsDataSource = FactsDataSource()
    public let factsDataSource: FactsDataSource!
    public var axis: Axis!
    
    private let _alertMessage = PublishSubject<(String,String)>()

    // MARK: - Inputs
    let chooseFact: AnyObserver<CensusFact>
    
    // MARK: - Outputs
    let alertMessage: Observable<(String,String)>
    let didChooseFact: Observable<CensusFact>
    
    init(axis: Axis, dataSource: CensusDataSource) {
        
        self.axis = axis
        self.factsDataSource = FactsDataSource(dataSource: dataSource)
        self.alertMessage = _alertMessage.asObservable()
        
        let _chooseFact = PublishSubject<CensusFact>()
        self.chooseFact = _chooseFact.asObserver()
        self.didChooseFact = _chooseFact.asObservable()
        
        self.factsDataSource.alertMessage
            .bind(to: _alertMessage)
            .disposed(by: disposeBag)
        
    }
    
    public func factAtIndexPath(_ indexPath: IndexPath) -> CensusFact {
        return factsDataSource.getFact(at: indexPath)
    }
    
}
