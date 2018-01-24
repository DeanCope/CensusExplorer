//
//  SettingsViewViewModel.swift
//  CensusAPI
//
//  Created by Dean Copeland on 10/8/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import Foundation
import Charts

struct SettingsViewModel {
    // MARK: - Properties
    
    let numberFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 1
        return nf
    } ()
    
    var chartLineWidthFloat: Float {
        return UserDefaults.chartLineWidth()
    }
    
    var chartLineWidthString: String {
        return numberFormatter.string(for: UserDefaults.chartLineWidth()) ?? ""
    }
    
    var chartShowValues: Bool {
        return UserDefaults.chartShowValues()
    }
    
    var lineChartMode: LineChartDataSet.Mode {
        return UserDefaults.lineChartMode()
    }
    
}
