//
//  Store.swift
//  CoordinatorKitDemo
//
//  Created by Ian MacCallum on 11/1/17.
//

import Foundation

/*
protocol StoreDelegate: class {
    func store(_ store: StoreType, didChangeLogginState isLoggedIn: Bool)
}
 */

protocol StoreType: class {
    func getChartSpecs(chartType: ChartType) -> ChartSpecs
    func setChartSpecs(chartType: ChartType, chartSpecs: ChartSpecs)
}

/*
 The point of this project is not the store much so
 I'm making it as simple as possible. The store holds your service layer which
 should include your network and caching layers. I would probably use reactive
 components instead of delegation here so you can just bind your coordinator
 to variables but I'm trying to avoid using any third party libraries in this
 project.
*/
class Store: NSObject, StoreType {
    
  //  weak var delegate: StoreDelegate?
    
 /*   var isLoggedIn: Bool = false {
        didSet {
            delegate?.store(self, didChangeLogginState: isLoggedIn)
        }
    }

    
    var token: String? {
        didSet {
            isLoggedIn = token != nil
        }
    }
  */
    
    //var chartSpecs: ChartSpecs?
    private var _chartSpecs: [ChartType:ChartSpecs]
    
    func getChartSpecs(chartType: ChartType) -> ChartSpecs {
            return _chartSpecs[chartType]!
    }
    
    func setChartSpecs(chartType: ChartType, chartSpecs: ChartSpecs) {
        _chartSpecs[chartType] = chartSpecs
    }
 
    override init() {
        _chartSpecs = [:]
        _chartSpecs[.line] = ChartSpecs(chartType: .line, factX: nil, factY: nil)
        _chartSpecs[.scatter] = ChartSpecs(chartType: .scatter, factX: nil, factY: nil)
    }
    
    
    //private let config: ConfigType
    /*
    init(config: ConfigType) {
        //self.config = config
        super.init()
    }
 */
}
