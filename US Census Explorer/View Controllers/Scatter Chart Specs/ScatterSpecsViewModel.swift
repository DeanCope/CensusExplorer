//
//  ScatterSpecsViewModel.swift
//  CensusAPI
//
//  Created by Dean Copeland on 10/22/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import RxSwift
import RxCocoa

class ScatterSpecsViewModel {
    
    private let disposeBag = DisposeBag()
    
    private var store: StoreType
    
    // MARK: - Inputs
    let selectItem: AnyObserver<ScatterSpecsCoordinator.ScatterSpecItem>
    let chooseContinue: AnyObserver<Void>
    
    // MARK: - Outputs
    let didSelectItem: Observable<ScatterSpecsCoordinator.ScatterSpecItem>
    let didChooseContinue: Observable<Void>
    
    var factXString: Driver<String> {
        return store.getChartSpecs(chartType: .scatter).factXString
            .map {
                return $0 ?? "Select a topic..."
            }
            .asDriver(onErrorJustReturn: "TBD")
    }
    
    var factYString: Driver<String> {
        return store.getChartSpecs(chartType: .scatter).factYString
            .map {
                return $0 ?? "Select a topic..."
            }
            .asDriver(onErrorJustReturn: "TBD")
    }
    
    var yearString: Driver<String> {
        return store.getChartSpecs(chartType: .scatter).yearString.asDriver(onErrorJustReturn: "TBD")
    }
    
    //factXNameLabel.text = chartSpecs?.factX?.factName ?? "Select a topic..."
    
    init(store: StoreType) {
        self.store = store
        
        let _selectItem = PublishSubject<ScatterSpecsCoordinator.ScatterSpecItem>()
        self.selectItem = _selectItem.asObserver()
        self.didSelectItem = _selectItem.asObservable()
        
        let _chooseContinue = PublishSubject<Void>()
        self.chooseContinue = _chooseContinue.asObserver()
        self.didChooseContinue = _chooseContinue.asObservable()
        
        //chartSpecs = ChartSpecs(chartType: .scatter, factX: nil, factY: nil, year: UserDefaults.defaultYear)
    }
    

    

    
}


