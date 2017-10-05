//
//  ScatterChartViewController.swift
//  CensusAPI
//
//  Created by Dean Copeland on 9/26/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit
import Charts

class ScatterChartViewController: UIViewController, ChartViewDelegate {

    @IBOutlet weak var chartView: ScatterChartView!
    
    @IBOutlet weak var yAxisLabelFrame: UIView!
    

    @IBOutlet weak var xAxisLabel: UILabel!
    
    // The geoLabel is like a "callout" box.  When the user touches a data point on the chart, it appears, dynamically poisitioned, with info about the data point.
    @IBOutlet weak var geoLabel: InsetLabel!
    
    var chartSpecs: ChartSpecs? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chartView.delegate = self
        geoLabel.isHidden = true
        geoLabel.translatesAutoresizingMaskIntoConstraints = true
        addYAxisLabel()
        addXAxisLabel()
    }
    
    func addYAxisLabel() {
        
        let yAxisLabel: UILabel = UILabel()
        yAxisLabel.frame = CGRect(x: 2, y: view.frame.maxY / 2, width: 10, height: 300)
        yAxisLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        yAxisLabel.textAlignment = .center
        yAxisLabel.text = chartSpecs?.factY?.factName ?? "Unknown Y axis name"
        yAxisLabel.numberOfLines=1
        yAxisLabel.font=UIFont.systemFont(ofSize: 12)
        
        view.addSubview(yAxisLabel)
        yAxisLabel.translatesAutoresizingMaskIntoConstraints = false
        yAxisLabel.centerXAnchor.constraint(equalTo: yAxisLabelFrame.centerXAnchor).isActive = true
        yAxisLabel.centerYAnchor.constraint(equalTo: yAxisLabelFrame.centerYAnchor).isActive = true
    }
    
    func addXAxisLabel() {
        xAxisLabel.text = chartSpecs?.factX?.factName ?? "Unknown Y axis name"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.refresh(self)
    }
    
    func refresh(_ sender: Any) {
        
        guard let factX = chartSpecs?.factX else {
            return
        }
        
        guard let factY = chartSpecs?.factY else {
            return
        }
        
        let formatter = CensusValueFormatter()
        
        let colors = [UIColor.red, .green, .blue, .black, .brown, .cyan, .gray ]
        //numberFormatter.numberStyle = .decimal
        CensusDataSource.sharedInstance.getSelectedGeographies() { (geographies, error) in
            if let _ = geographies {
                var dataSets: [ScatterChartDataSet] = []
                var dataSetNumber = 0
                for geography in geographies! {
                    CensusDataSource.sharedInstance.getDataFromDB(forFact: factX, geography: geography, year: 2015) {
                        (result, error) in
                        if let resultX = result {
                            CensusDataSource.sharedInstance.getDataFromDB(forFact: factY, geography: geography, year: 2015) {
                                (result, error) in
                                if let resultY = result {
                                    let dataSet = self.createDataSetFromCensusValues(valX: resultX, valY: resultY, label: geography.name!)
                                    dataSet.colors = ChartColorTemplates.colorful()
                                    if dataSetNumber < colors.count {
                                        dataSet.setColor(colors[dataSetNumber])
                                        //      dataSet.setCircleColor(colors[dataSetNumber])
                                    }
                                    
                                    dataSet.drawValuesEnabled = UserDefaults.standard.bool(forKey: UserDefaults.Keys.ChartShowValues)
                                    dataSet.valueFormatter = formatter
                                    
                                    //  dataSet.circleRadius = 2
                                    
                                    dataSetNumber += 1
                                    if dataSetNumber > colors.count {
                                        dataSetNumber = 0
                                    }
                                    dataSets.append(dataSet)
                                }
                            }
                        } else {
                            // prompt with error
                            print(error)
                        }
                    }
                }
                self.setChart(dataSets: dataSets)
            }
        }
    }
    
    func createDataSetFromCensusValues(valX: CensusValue, valY: CensusValue, label: String) -> ScatterChartDataSet {
    
        let entry = ChartDataEntry(x: valX.value, y: valY.value)
    
        let dataSet = ScatterChartDataSet(values: [entry], label: label)
        return dataSet
    }
    
    func setChart(dataSets: [ScatterChartDataSet]) {
        chartView.noDataText = "You need to provide data for the chart."
        
        let data = ScatterChartData(dataSets: dataSets)
        chartView.data = data
        
   //     titleLabel.text = fact?.factDescription
        
        chartView.chartDescription?.enabled = true
        chartView.chartDescription?.text = "Source: US Census Bureau"
        if dataSets.count < 11 {
            chartView.legend.enabled = true
            chartView.legend.drawInside = true
            chartView.legend.verticalAlignment = Legend.VerticalAlignment.top
        } else {
            chartView.legend.enabled = false
        }
        chartView.xAxis.labelPosition = .bottom
        
        chartView.xAxis.granularity = 1
        
        chartView.backgroundColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)
        
        chartView.animate(xAxisDuration: 1.0, yAxisDuration: 0.0)
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        if let dataSet = chartView.data?.dataSets[highlight.dataSetIndex] {
            geoLabel.layer.borderColor = dataSet.color(atIndex: 0).cgColor
            geoLabel.layer.borderWidth = 1.0
            geoLabel.layer.cornerRadius = 8
            
            // Dynamically position the label
            var xPosition = highlight.xPx
            if xPosition > view.frame.maxX - 95 {
                xPosition = view.frame.maxX - 95
            }
            if xPosition < view.frame.minX + 95 {
                xPosition = view.frame.minX + 95
            }
            var yPosition = highlight.yPx
            if yPosition > view.frame.maxY - 10 {
                yPosition = view.frame.maxY - 10
            }
            if yPosition < view.frame.minY + 140 {
                yPosition = view.frame.minY + 140
            }
            /*
            var year = String(entry.x)
            let index = year.index(year.startIndex, offsetBy: 5)
            year = year.substring(to: index)
 */
            if let factX = chartSpecs?.factX, let factY = chartSpecs?.factY  {
                var message = ""
                if factX.unit! == "$" {
                    message = "\(dataSet.label!): \(factX.unit!)\(entry.x) \(factX.factName!)"
                } else {
                    message = "\(dataSet.label!): \(entry.x)\(factX.unit!) \(factX.factName!)"
                }
                if factY.unit! == "$" {
                    message = message + " and \(factY.unit!)\(entry.y) \(factY.factName!)"
                } else {
                   message = message + " and \(entry.y)\(factY.unit!) \(factY.factName!)"
                }
                geoLabel.text = message
            }
            
            geoLabel.sizeToFit()
            geoLabel.isHidden = false
            
            geoLabel.center = CGPoint(x: xPosition, y: yPosition)
        }
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        geoLabel.text = ""
        geoLabel.isHidden = true
    }
    
}
