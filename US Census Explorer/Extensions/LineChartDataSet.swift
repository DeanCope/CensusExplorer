//
//  LineChartDataSet.swift
//  CensusAPI
//
//  Created by Dean Copeland on 10/8/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import Foundation
import Charts

extension LineChartDataSet.Mode {
    var name: String {
        switch self {
        case .cubicBezier: return "Cubic Bezier"
        case .horizontalBezier: return "Horizonal Bezier"
        case .linear: return "Linear"
        case .stepped: return "Stepped"
        }
    }
}
