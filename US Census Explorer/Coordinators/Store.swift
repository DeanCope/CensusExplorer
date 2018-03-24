//
//  Store.swift
//  CoordinatorKitDemo
//
//  Created by Ian MacCallum on 11/1/17.
//

import Foundation


protocol StoreType: class {
    func getDataSource() -> CensusDataSource
    func getChartSpecs(chartType: ChartType) -> ChartSpecs
    func setChartSpecs(chartType: ChartType, chartSpecs: ChartSpecs)
}

class Store: NSObject, StoreType {
    
    private var _chartSpecs: [ChartType: ChartSpecs]
    private var _dataSource: CensusDataSource
    
    func getDataSource() -> CensusDataSource {
        return _dataSource
    }
    
    func getChartSpecs(chartType: ChartType) -> ChartSpecs {
            return _chartSpecs[chartType]!
    }
    
    func setChartSpecs(chartType: ChartType, chartSpecs: ChartSpecs) {
        _chartSpecs[chartType] = chartSpecs
    }
 
    override init() {
        _dataSource = CensusDataSource()
        _chartSpecs = [:]
        _chartSpecs[.line] = ChartSpecs(chartType: .line, factX: nil, factY: nil)
        _chartSpecs[.scatter] = ChartSpecs(chartType: .scatter, factX: nil, factY: nil)
    }
}
