//
//  CensusLineChartView+Rx.swift
//  CensusAPI
//
//  Created by Dean Copeland on 3/28/18.
//  Copyright © 2018 Dean Copeland. All rights reserved.
//

import RxSwift
import RxCocoa

extension Reactive where Base: CensusLineChartView {
    
    var noDataText: Binder<String> {
        return Binder(self.base) { chartView, text in
            chartView.noDataText = text
        }
    }
    
    var xAxisLabel: Binder<String?> {
        return Binder(self.base) { chartView, xAxisLabel in
            chartView.xAxisLabelText = xAxisLabel ?? ""
        }
    }
    
    var needsDisplay: Binder<Bool> {
        return Binder(self.base) { chartView, needsDisplay in
            chartView.setNeedsDisplay()
        }
    }
}
