//
//  ChartViewBase+Rx.swift
//  CensusAPI
//
//  Created by Dean Copeland on 3/31/18.
//  Copyright © 2018 Dean Copeland. All rights reserved.
//

import RxSwift
import RxCocoa
import Charts

extension Reactive where Base: ChartViewBase {
    
    var noDataText: Binder<String> {
        return Binder(self.base) { chartView, text in
            chartView.noDataText = text
        }
    }
}
