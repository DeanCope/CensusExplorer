//
//  GeosViewModel.swift
//  CensusAPI
//
//  Created by Dean Copeland on 12/18/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import RxSwift
import RxCocoa

class GeosViewModel {
    private let disposeBag = DisposeBag()
    
    private let censusDataSource: CensusDataSource!
    public let geosDataSource: GeosDataSource!
    
    // MARK: - Inputs
    let graphIt: AnyObserver<Void>
    let cancel: AnyObserver<Void>
    let selectGeo: AnyObserver<Geography>
    let deselectGeo: AnyObserver<Geography>
    let selectAll: AnyObserver<Void>
    let deselectAll: AnyObserver<Void>
    
    // MARK: - Outputs
    let alertMessage: Observable<(String, String)>
    let dataChanged: Observable<Void>
    let didChooseGraphIt: Observable<Void>
    let didCancel: Observable<Void>
    let didSelectGeo: Observable<Geography>
    let didDeselectGeo: Observable<Geography>
    let didSelectAll: Observable<Void>
    let didDeselectAll: Observable<Void>
    
    // RXSwift drivers - Output to UI
    var querying: Driver<Bool> { return censusDataSource.querying }
    var title: Driver<String> { return _title.asDriver() }
    
    // MARK: -
    //RxSwift Private Variables
    private let _dataChanged = PublishSubject<Void>()
    private let _alertMessage = PublishSubject<(String, String)>()
    private let _title: Variable<String>
    
    init(dataSource: CensusDataSource, chartSpecs: ChartSpecs) {
        self.censusDataSource = dataSource
        self.geosDataSource = GeosDataSource(dataSource: dataSource)
        
        self.alertMessage = _alertMessage.asObservable()
        
        self._title = Variable<String>(chartSpecs.description)
        
        self.dataChanged = _dataChanged.asObservable()
        
        let _graphIt = PublishSubject<Void>()
        self.graphIt = _graphIt.asObserver()
        self.didChooseGraphIt = _graphIt.asObservable()
        
        let _cancel = PublishSubject<Void>()
        self.cancel = _cancel.asObserver()
        self.didCancel = _cancel.asObservable()
        
        let _selectGeo = PublishSubject<Geography>()
        self.selectGeo = _selectGeo.asObserver()
        self.didSelectGeo = _selectGeo.asObservable()
        
        let _deselectGeo = PublishSubject<Geography>()
        self.deselectGeo = _deselectGeo.asObserver()
        self.didDeselectGeo = _deselectGeo.asObservable()
        
        let _selectAll = PublishSubject<Void>()
        self.selectAll = _selectAll.asObserver()
        self.didSelectAll = _selectAll.asObservable()
        
        let _deselectAll = PublishSubject<Void>()
        self.deselectAll = _deselectAll.asObserver()
        self.didDeselectAll = _deselectAll.asObservable()
        
        didSelectGeo
            .subscribe(onNext: { [weak self] geo in
                self?.geosDataSource.selectGeography(geo: geo, selected: true)
            })
            .disposed(by: disposeBag)
        
        didDeselectGeo
            .subscribe(onNext: { [weak self] geo in
                self?.geosDataSource.selectGeography(geo: geo, selected: false)
            })
            .disposed(by: disposeBag)
        
        didSelectAll
            .subscribe(onNext: { [weak self] in
                self?.censusDataSource.selectAllGeographies(true){ (success, error) in
                    if success {
                        self?._dataChanged.onNext(())
                    } else {
                        var message = "Error selecting all rows"
                        if let error = error {
                            message = message + ": \(error.localizedDescription)"
                        }
                        self?._alertMessage.onNext(("Error",message))
                    }
                }
            })
            .disposed(by: disposeBag)
        
        didDeselectAll
            .subscribe(onNext: { [weak self] in
                self?.censusDataSource.selectAllGeographies(false){ (success, error) in
                    if success {
                        self?._dataChanged.onNext(())
                    } else {
                        var message = "Error selecting all rows"
                        if let error = error {
                            message = message + ": \(error.localizedDescription)"
                        }
                        self?._alertMessage.onNext(("Error",message))
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    public func geoAtIndexPath(_ indexPath: IndexPath) -> Geography {
        return geosDataSource.getGeography(at: indexPath)
    }
    
}
