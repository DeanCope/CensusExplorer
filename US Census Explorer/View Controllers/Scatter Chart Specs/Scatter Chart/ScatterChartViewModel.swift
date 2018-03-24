//
//  ScatterChartViewViewModel.swift
//  CensusAPI
//
//  Created by Dean Copeland on 10/18/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import RxSwift
import RxCocoa
import Charts
// This struct is responsible for retrieving scatter chart data from the model (CensusDataSource) and
// formatting it for easy consuption by the census scatter chart view.
struct ScatterChartViewModel {
    
    let disposeBag = DisposeBag()
    
    private let censusDataSource: CensusDataSource!
    private let _titleText: Variable<String>
    
    // MARK: - Inputs
    let save: AnyObserver<Void>
    
    // MARK: - Outputs
    let didChooseSave: Observable<Void>
    
    //RXSwift Drivers
    var titleText: Driver<String> { return _titleText.asDriver() }
    
    var chartSpecs: ChartSpecs
    var chartData: ScatterChartData?
    
    let numberFormatter = NumberFormatter()
    let colors = [UIColor.red, .green, .blue, .black, .brown, .cyan, .gray ]
    
    init(dataSource: CensusDataSource, chartSpecs: ChartSpecs) {
        self.censusDataSource = dataSource
        self.chartSpecs = chartSpecs
        
        self._titleText = Variable<String>(chartSpecs.factY.value?.factDescription ?? "")
        
        let _save = PublishSubject<Void>()
        self.save = _save.asObserver()
        self.didChooseSave = _save.asObservable()
        
        guard let factX = chartSpecs.factX.value  else { return }
        guard let factY = chartSpecs.factY.value  else { return }
        
        let formatter = CensusValueFormatter()
        numberFormatter.numberStyle = .decimal
        
        guard let geographies = censusDataSource.getSelectedGeographies()  else { return }
        var dataSets: [ScatterChartDataSet] = []
        var dataSetNumber = 0
        for geography in geographies {
            if let resultX = censusDataSource.getDataFromDB(forFact: factX, geography: geography, year: chartSpecs.year.value) {
                if let resultY = censusDataSource.getDataFromDB(forFact: factY, geography: geography, year: chartSpecs.year.value) {
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
    
    /*
    var titleText: String {
        get {
            return chartSpecs.factY.value?.factDescription ?? ""
        }
    }
    */
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
