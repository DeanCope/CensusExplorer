//
//  LineChartViewModel.swift
//  CensusAPI
//
//  Created by Dean Copeland on 10/16/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import RxSwift
import RxCocoa
import Charts
// This struct is responsible for retrieving line chart data from the model (CensusDataSource) and
// formatting it for easy consumption by the census line chart view.
class LineChartViewModel {
    
    let disposeBag = DisposeBag()
    
    private let censusDataSource: CensusDataSource!
    private let _noDataText: Variable<String>
    private let _titleText: Variable<String>
    private let _xAxisText: Variable<String>
    private let _needsDisplay: Variable<Bool>
    
    // MARK: - Inputs
    let save: AnyObserver<Void>
    
    // MARK: - Outputs
    let didChooseSave: Observable<Void>
    
    //RXSwift Drivers
    var noDataText: Driver<String> { return _noDataText.asDriver() }
    var titleText: Driver<String> { return _titleText.asDriver() }
    var xAxisText: Driver<String> { return _xAxisText.asDriver() }
    var needsDisplay: Driver<Bool> { return _needsDisplay.asDriver() }

    var chartSpecs: ChartSpecs
    var chartData: LineChartData?
    
    let numberFormatter = NumberFormatter()
    let colors = [UIColor.red, .green, .blue, .black, .brown, .cyan, .gray ]
    
    init(dataSource: CensusDataSource, chartSpecs: ChartSpecs) {
        self.censusDataSource = dataSource
        self.chartSpecs = chartSpecs
        
        self._noDataText = Variable<String>("You need to provide data for the chart.")
        self._titleText = Variable<String>(chartSpecs.factY.value?.factDescription ?? "")
        self._xAxisText = Variable<String>("Years")
        self._needsDisplay = Variable<Bool>(false)
        
        let _save = PublishSubject<Void>()
        self.save = _save.asObserver()
        self.didChooseSave = _save.asObservable()
        
        UserDefaults.standard.chartLineWidthObservable
            .subscribe(onNext: { [weak self] event in
                self?.refreshSettings()
            })
            .disposed(by: disposeBag)
        UserDefaults.standard.chartShowValuesObservable
            .subscribe(onNext: { [weak self] event in
                self?.refreshSettings()
            })
            .disposed(by: disposeBag)
        UserDefaults.standard.lineChartModeObservable
            .subscribe(onNext: { [weak self] event in
                self?.refreshSettings()
            })
            .disposed(by: disposeBag)
        
        guard let fact = chartSpecs.factY.value  else { return }
        guard fact.variableName != nil else { return }
        
        let formatter = CensusValueFormatter()
        numberFormatter.numberStyle = .decimal
        
        guard let geographies = censusDataSource.getSelectedGeographies()  else { return }
        var dataSets: [LineChartDataSet] = []
        var dataSetNumber = 0
        for geography in geographies {
            if let result = censusDataSource.getDataFromDB(forFact: fact, geography: geography) {
                let dataSet = self.createDataSetFromCensusValues(result, label: geography.name!)
                dataSet.colors = ChartColorTemplates.colorful()
                if dataSetNumber < colors.count {
                    dataSet.setColor(colors[dataSetNumber])
                    dataSet.setCircleColor(colors[dataSetNumber])
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
        self.chartData = LineChartData(dataSets: dataSets)
        
    }
    
    public func refreshSettings() {
        guard let dataSets = chartData?.dataSets as? [LineChartDataSet] else {return}
        for dataSet in dataSets {
            setDataSetProperties(dataSet)
        }
        self._needsDisplay.value = true
    }
    
    private func createDataSetFromCensusValues(_ values: [CensusValue], label: String) -> LineChartDataSet {
        var entries: [ChartDataEntry] = []
        
        for value in values {
            let entry = ChartDataEntry(x: Double(value.year), y: value.value)
            entries.append(entry)
        }
        let dataSet = LineChartDataSet(values: entries, label: label)
        return dataSet
    }
    
    private func setDataSetProperties(_ dataSet: LineChartDataSet) {
        dataSet.lineWidth = CGFloat(UserDefaults.chartLineWidth())
        dataSet.drawValuesEnabled = UserDefaults.chartShowValues()
        dataSet.mode = UserDefaults.lineChartMode()
        dataSet.circleRadius = 2
    }
    
    var yAxisText: String {
        get {
            return chartSpecs.factY.value?.factName ?? "Unknown Y axis name"
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

