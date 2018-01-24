//
//  ChartSpecs.swift
//  CensusAPI
//
//  Created by Dean Copeland on 9/29/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol ChartSpecsType: class {
    
    var chartType: ChartType {get}
    var factX: Variable<CensusFact?> {get}
    var factY: Variable<CensusFact?> {get}
    var year: Variable<Int16> {get}
    var description: String {get}
}

class ChartSpecs: ChartSpecsType {
    
    private let disposeBag = DisposeBag()
    
    var chartType: ChartType = .line
    var factX = Variable<CensusFact?>(nil)
    var factY = Variable<CensusFact?>(nil)
    var year = Variable<Int16>(2016)
    
    let yearString: Observable<String>
    let factXString: Observable<String?>
    let factYString: Observable<String?>
    
    var description: String {
        switch chartType {
        case .line: return factY.value?.factName ?? ""
        case .scatter:
            switch (factX.value?.factName, factY.value?.factName) {
            case (.some, .some): return "\(factY.value!.factName!) vs \(factX.value!.factName!)"
            default: return ""
            }
        }
    }
    
    init(chartType: ChartType, factX: CensusFact?, factY: CensusFact?) {
        self.chartType = chartType
        self.factX.value = factX
        self.factY.value = factY
        
        self.yearString = year
            .asObservable()
            .map {
                "\($0)"
            }
        
        self.factXString = self.factX
            .asObservable()
            .map {
                $0?.factName
            }
        
        self.factYString = self.factY
            .asObservable()
            .map {
                $0?.factName
            }
    }
    
    func getFact(forAxis: Axis) -> CensusFact? {
        if forAxis == .x {
            return factX.value
        } else {
            return factY.value
        }
    }
    
    func setFact(_ fact: CensusFact, forAxis: Axis) {
        if forAxis == .x {
            factX.value = fact
        } else {
            factY.value = fact
        }
    }

}

