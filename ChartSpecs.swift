//
//  ChartSpecs.swift
//  CensusAPI
//
//  Created by Dean Copeland on 9/29/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import Foundation

struct ChartSpecs {
    var chartType: ChartType
    var factX: CensusFact?
    var factY: CensusFact?
    var year: Int16?
    
    var description: String {
        switch chartType {
        case .line: return factY?.factName ?? ""
        case .scatter:
            switch (factX?.factName, factY?.factName) {
            case (.some, .some): return "\(factY!.factName!) vs \(factX!.factName!)"
            default: return ""
            }
        }
    }
    
    func getFact(forAxis: Axis) -> CensusFact? {
        if forAxis == .x {
            return factX
        } else {
            return factY
        }
    }
    
    mutating func setFact(_ fact: CensusFact, forAxis: Axis) {
        if forAxis == .x {
            factX = fact
        } else {
            factY = fact
        }
    }
}

protocol SettableChartSpecs: class {
    var chartSpecs: ChartSpecs? {get set}
}
