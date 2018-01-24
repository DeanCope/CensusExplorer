//
//  ScatterChartViewViewModel.swift
//  CensusAPI
//
//  Created by Dean Copeland on 10/18/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import Foundation
import Charts
// This struct is responsible for retrieving line chart data from the model (CensusDataSource) and
// formatting it for easy consuption by the census line chart view.
struct ScatterChartViewModel {
    
    var chartSpecs: ChartSpecs
    var chartData: ScatterChartData?
    
    let numberFormatter = NumberFormatter()
    let colors = [UIColor.red, .green, .blue, .black, .brown, .cyan, .gray ]
    
    init(chartSpecs: ChartSpecs) {
        self.chartSpecs = chartSpecs
        
        guard let factX = chartSpecs.factX.value  else { return }
        guard let factY = chartSpecs.factY.value  else { return }
        
        let formatter = CensusValueFormatter()
        numberFormatter.numberStyle = .decimal
        
        guard let geographies = CensusDataSource.sharedInstance.getSelectedGeographies()  else { return }
        var dataSets: [ScatterChartDataSet] = []
        var dataSetNumber = 0
        for geography in geographies {
            if let resultX = CensusDataSource.sharedInstance.getDataFromDB(forFact: factX, geography: geography, year: chartSpecs.year.value) {
                if let resultY = CensusDataSource.sharedInstance.getDataFromDB(forFact: factY, geography: geography, year: chartSpecs.year.value) {
                    let dataSet = self.createDataSetFromCensusValues(valX: resultX, valY: resultY, label: geography.name!)
                    dataSet.colors = ChartColorTemplates.colorful()
                    if dataSetNumber < colors.count {
                        dataSet.setColor(colors[dataSetNumber])
                   //     dataSet.setCircleColor(colors[dataSetNumber])
                    }
                    self.setDataSetProperties(dataSet)
                    dataSet.valueFormatter = formatter
                    dataSetNumber += 1
                    if dataSetNumber > colors.count {
                        dataSetNumber = 0
                    }
                    dataSets.append(dataSet)
                }
            }
        }
        self.chartData = ScatterChartData(dataSets: dataSets)
        
    }
    
    private func createDataSetFromCensusValues(valX: CensusValue, valY: CensusValue, label: String) -> ScatterChartDataSet {
        
        let entry = ChartDataEntry(x: valX.value, y: valY.value)
        
        let dataSet = ScatterChartDataSet(values: [entry], label: label)
        return dataSet
    }
    
    private func setDataSetProperties(_ dataSet: ScatterChartDataSet) {
        dataSet.drawValuesEnabled = UserDefaults.chartShowValues()
    }
    
    var xAxisText: String {
        get {
            return chartSpecs.factX.value?.factName ?? "Unknown X axis name"
        }
    }
    
    var yAxisText: String {
        get {
            return chartSpecs.factY.value?.factName ?? "Unknown Y axis name"
        }
    }
    
    var titleText: String {
        get {
            return chartSpecs.factY.value?.factDescription ?? ""
        }
    }
    
    var shouldDisplayLegend: Bool {
        get {
            if let count = chartData?.dataSetCount {
                return count < 11
            } else {
                return false
            }
        }
    }
    
    var chartBackgroundColor: UIColor {
        get {
            return UserDefaults.chartBackgroundColor()
        }
    }
    
    
    
}
