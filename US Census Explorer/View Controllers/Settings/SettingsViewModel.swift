//
//  SettingsViewViewModel.swift
//  CensusAPI
//
//  Created by Dean Copeland on 10/8/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import Foundation
import Charts
import RxSwift
import RxCocoa

struct SettingsViewModel {
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Inputs (From the UI)
    let chartLineWidthObserver: AnyObserver<Float>
    let chartShowValuesObserver: AnyObserver<Bool>
    let lineChartModeObserver: AnyObserver<LineChartDataSet.Mode>
    let showInstructionsObserver: AnyObserver<Bool>
    let requestCloseObserver: AnyObserver<Void>
    
    // MARK: - Outputs (To UI and Coordinator)
    let alertMessageObservable: Observable<(String,String)>
    let didRequestCloseObservable: Observable<Void>
    
    // RXSwift drivers - Output to UI
    var chartLineWidthStringDriver: Driver<String> {
        return UserDefaults.standard.chartLineWidthObservable
            .map { token in
                guard let token = token else {return ""}
                return self.numberFormatter.string(for: token)!
            }
            .asDriver(onErrorJustReturn: "")
    }
    
    // MARK: - RxSwift Private Variables
    private let _alertMessageSubject = ReplaySubject<(String,String)>.create(bufferSize: 1)
    
    // MARK: - Properties
    
    let numberFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 1
        return nf
    } ()
    
    var chartLineWidthFloat: Float {
        return UserDefaults.chartLineWidth()
    }
    
    var chartShowValues: Bool {
        return UserDefaults.chartShowValues()
    }
    
    var lineChartMode: LineChartDataSet.Mode {
        return UserDefaults.lineChartMode()
    }
    
    var showInstructions: Bool {
        return UserDefaults.showLineChartInstructions()
    }
    
    init() {
        self.alertMessageObservable = _alertMessageSubject.asObservable()
        
        let _chartLineWidthSubject = PublishSubject<Float>()
        self.chartLineWidthObserver = _chartLineWidthSubject.asObserver()
        
        let _chartShowValuesSubject = PublishSubject<Bool>()
        self.chartShowValuesObserver = _chartShowValuesSubject.asObserver()
        
        let _lineChartModeSubject = PublishSubject<LineChartDataSet.Mode>()
        self.lineChartModeObserver = _lineChartModeSubject.asObserver()
        
        let _showInstructionsSubject = PublishSubject<Bool>()
        self.showInstructionsObserver = _showInstructionsSubject.asObserver()
        
        let _requestCloseSubject = PublishSubject<Void>()
        self.requestCloseObserver = _requestCloseSubject.asObserver()
        self.didRequestCloseObservable = _requestCloseSubject.asObservable()
        
        _chartLineWidthSubject
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { width in
                //print("Changing Chart Line Width to: \(width)")
                UserDefaults.setChartLineWidth(width)
            })
        .disposed(by: disposeBag)
        
        _chartShowValuesSubject
            .subscribe(onNext: { show in
                UserDefaults.setChartShowValues(show)
            })
            .disposed(by: disposeBag)
        
        _lineChartModeSubject
            .subscribe(onNext: { mode in
                UserDefaults.setLineChartMode(mode)
            })
            .disposed(by: disposeBag)
        
        _showInstructionsSubject
            .subscribe(onNext: { show in
                UserDefaults.setShowLineChartInstruction(show)
                UserDefaults.setShowGeoInstructions(show)
            })
            .disposed(by: disposeBag)
    }
    
}
