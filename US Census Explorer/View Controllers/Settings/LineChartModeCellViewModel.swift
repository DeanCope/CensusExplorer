//
//  LineChartModeCellViewModel.swift
//  CensusAPI
//
//  Created by Dean Copeland on 10/12/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import Foundation
import Charts

struct LineChartModeCellViewModel {
    
    var mode: LineChartDataSet.Mode?
    
    var viewModel: SettingsViewModel
    
    var selected: Bool {
        return mode == viewModel.lineChartMode
    }
    
    var text: String {
        return mode?.name ?? ""
    }
}
