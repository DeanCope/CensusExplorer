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
    
    var xAxisText: Binder<String?> {
        return Binder(self.base) { chartView, xAxisText in
            chartView.xAxisText = xAxisText ?? ""
        }
    }
   
    var needsDisplay: Binder<Bool> {
        return Binder(self.base) { chartView, needsDisplay in
            chartView.setNeedsDisplay()
        }
    }
}
