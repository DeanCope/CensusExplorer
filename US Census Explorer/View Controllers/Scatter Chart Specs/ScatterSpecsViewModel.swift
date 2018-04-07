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
    
    // MARK: - Inputs (From the UI)
    let selectItem: AnyObserver<ScatterSpecsCoordinator.ScatterSpecItem>
    let requestFactDetails: AnyObserver<CensusFact?>
    let chooseContinue: AnyObserver<Void>
    
    // MARK: - Outputs (To UI and Coordinator)
    let alertMessage: Observable<(String,String)>
    let didSelectItem: Observable<ScatterSpecsCoordinator.ScatterSpecItem>
    let didRequestFactDetails: Observable<CensusFact?>
    let didChooseContinue: Observable<Void>
    let everythingValid: Observable<Bool>
    
    // RXSwift drivers - Output to UI
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
    
    // MARK: - RxSwift Private Variables
    private let _alertMessage = ReplaySubject<(String,String)>.create(bufferSize: 1)
    
    public func factAtIndexPath(_ indexPath: IndexPath) -> CensusFact? {
        if indexPath.section == 1 {
            // X Axis
            return store.getChartSpecs(chartType: .scatter).factX.value
        } else {
            // Y Axis
            return store.getChartSpecs(chartType: .scatter).factY.value
        }
    }
    
    init(store: StoreType) {
        self.store = store
        
        self.alertMessage = _alertMessage.asObservable()
        
        let _selectItem = PublishSubject<ScatterSpecsCoordinator.ScatterSpecItem>()
        self.selectItem = _selectItem.asObserver()
        self.didSelectItem = _selectItem.asObservable()
        
        let _chooseContinue = PublishSubject<Void>()
        self.chooseContinue = _chooseContinue.asObserver()
        self.didChooseContinue = _chooseContinue.asObservable()
        
        let _requestFactDetails = PublishSubject<CensusFact?>()
        self.requestFactDetails = _requestFactDetails.asObserver()
        self.didRequestFactDetails = _requestFactDetails.asObservable()
        
        let factXChosen = store.getChartSpecs(chartType: .scatter).factX
            .asObservable()
            .map { $0 != nil }
            .share(replay: 1)
        
        let factYChosen = store.getChartSpecs(chartType: .scatter).factY
            .asObservable()
            .map { $0 != nil }
            .share(replay: 1)
        
       everythingValid = Observable.combineLatest(factXChosen, factYChosen) { $0 && $1 }
            .share(replay: 1)
        
        didRequestFactDetails
            .subscribe(onNext: { [weak self] fact in
                guard let fact = fact else {
                    return
                }
                self?._alertMessage.onNext((fact.factName ?? "Unknown", fact.factDescription ?? "Unknown"))
            })
            .disposed(by: disposeBag)
    }
    
}


