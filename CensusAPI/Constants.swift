//
//  Constants.swift
//  CensusAPI
//
//  Created by Dean Copeland on 2/14/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import Foundation

    struct Defaults {
    
        // MARK: Defaults
    
        static let HasLaunchedBeforeKey = "HasLaunchedBefore"
        
        static let ChartLineWidthKey = "ChartLineWidth"
        static let DefaultChartLineWidth = Float(2.0)
        
        static let ChartShowValuesKey = "ChartShowValues"
        static let DefaultChartShowValues = false
        
        static let ChartCubicSmoothingKey = "ChartCubicSmoothing"
        static let DefaultChartCubicSmoothing = false
        
    }

struct NotificationNames {
    static let GotCensusValues = "GotCensusValues"
    static let GotGeographies = "GotGeographies"
}

