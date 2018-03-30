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
    let setChartLineWidth: AnyObserver<Float>
    let setChartShowValues: AnyObserver<Bool>
    let setLineChartMode: AnyObserver<LineChartDataSet.Mode>
    let requestClose: AnyObserver<Void>
    
    // MARK: - Outputs (To UI and Coordinator)
    let alertMessage: Observable<(String,String)>
    let didRequestClose: Observable<Void>
    
    // RXSwift drivers - Output to UI
    var chartLineWidthStringDriver: Driver<String> {
        return UserDefaults.standard.chartLineWidthObservable
            .map { token in
                return self.numberFormatter.string(for: token ?? "")!
            }
            .asDriver(onErrorJustReturn: "")
    }
    
    // MARK: - RxSwift Private Variables
    private let _alertMessage = ReplaySubject<(String,String)>.create(bufferSize: 1)
    
    //private let _chartLineWidthString = Variable<String>("")

    
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
    
    init() {
        self.alertMessage = _alertMessage.asObservable()
        
        let _setChartLineWidth = PublishSubject<Float>()
        self.setChartLineWidth = _setChartLineWidth.asObserver()
        
        let _setChartShowValues = PublishSubject<Bool>()
        self.setChartShowValues = _setChartShowValues.asObserver()
        
        let _setLineChartMode = PublishSubject<LineChartDataSet.Mode>()
        self.setLineChartMode = _setLineChartMode.asObserver()
        
        let _requestClose = PublishSubject<Void>()
        self.requestClose = _requestClose.asObserver()
        self.didRequestClose = _requestClose.asObservable()
        
        _setChartLineWidth
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { width in
                //print("Changing Chart Line Width to: \(width)")
                UserDefaults.setChartLineWidth(width)
            })
        .disposed(by: disposeBag)
        
        _setChartShowValues
            .subscribe(onNext: { show in
                //print("Changing Chart Show Values to: \(show)")
                UserDefaults.setChartShowValues(show)
            })
            .disposed(by: disposeBag)
        
        _setLineChartMode
            .subscribe(onNext: { mode in
                //print("Changing Line Chart Mode to: \(mode.name)")
                UserDefaults.setLineChartMode(mode)
            })
            .disposed(by: disposeBag)
    }
    
}
