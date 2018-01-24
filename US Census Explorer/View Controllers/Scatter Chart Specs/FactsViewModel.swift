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
    
    var factsDataSource = FactsDataSource()
    
    var axis: Axis!
    
    private let _alertMessage = PublishSubject<String>()

    // MARK: - Inputs
    let chooseFact: AnyObserver<CensusFact>
    
    // MARK: - Outputs
    let alertMessage: Observable<String>
    let didChooseFact: Observable<CensusFact>
    
    init(axis: Axis) {
        
        self.axis = axis
        self.alertMessage = _alertMessage.asObservable()
        
        let _chooseFact = PublishSubject<CensusFact>()
        self.chooseFact = _chooseFact.asObserver()
        self.didChooseFact = _chooseFact.asObservable()
        
    }
    
    public func factAtIndexPath(_ indexPath: IndexPath) -> CensusFact {
        return factsDataSource.getFact(at: indexPath)
    }
    
}
