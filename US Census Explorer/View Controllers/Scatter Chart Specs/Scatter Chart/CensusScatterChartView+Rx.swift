//
//  CensusScatterChartView+Rx.swift
//  CensusAPI
//
//  Created by Dean Copeland on 3/31/18.
//  Copyright © 2018 Dean Copeland. All rights reserved.
//

import RxSwift
import RxCocoa

extension Reactive where Base: CensusScatterChartView {
    
    var xAxisText: Binder<String?> {
        return Binder(self.base) { chartView, xAxisText in
            chartView.xAxisText = xAxisText ?? ""
        }
    }
}
