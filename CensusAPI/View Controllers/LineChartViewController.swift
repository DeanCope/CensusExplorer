//
//  LineChartViewController.swift
//  CensusAPI
//
//  Created by Dean Copeland on 6/23/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//
import UIKit
import Charts

class LineChartViewController: UIViewController, ChartViewDelegate {

    @IBOutlet weak var chartView: LineChartView!
    
    // The geoLabel is like a "callout" box.  When the user touches a data point on the chart, it appears, dynamically poisitioned, with info about the data point.
    @IBOutlet weak var geoLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yAxisLabelFrame: UIView!
    
    var chartSpecs: ChartSpecs? = nil
    
    let numberFormatter = NumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chartView.delegate = self
        geoLabel.isHidden = true
        geoLabel.translatesAutoresizingMaskIntoConstraints = true
        
        addYAxisLabel()
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.refresh(self)
    }
    
    func refresh(_ sender: Any) {
        
        guard let fact = chartSpecs?.factY else {
            return
        }
        
        let formatter = CensusValueFormatter()
        numberFormatter.numberStyle = .decimal
        
        let colors = [UIColor.red, .green, .blue, .black, .brown, .cyan, .gray ]
        
        CensusDataSource.sharedInstance.getSelectedGeographies() { (geographies, error) in
            if let _ = geographies {
                var dataSets: [LineChartDataSet] = []
                var dataSetNumber = 0
                for geography in geographies! {
                    CensusDataSource.sharedInstance.getDataFromDB(forFact: fact, geography: geography) {
                        (result, error) in
                        if let _ = result {
                            let dataSet = self.createDataSetFromCensusValues(result!, label: geography.name!)
                            dataSet.colors = ChartColorTemplates.colorful()
                            if dataSetNumber < colors.count {
                                dataSet.setColor(colors[dataSetNumber])
                                dataSet.setCircleColor(colors[dataSetNumber])
                            }
                            
                            dataSet.lineWidth = CGFloat(UserDefaults.standard.float(forKey: UserDefaults.Keys.ChartLineWidth))
                            dataSet.drawValuesEnabled = UserDefaults.standard.bool(forKey: UserDefaults.Keys.ChartShowValues)
                            if UserDefaults.standard.bool(forKey: UserDefaults.Keys.ChartCubicSmoothing) {
                                dataSet.mode = .cubicBezier
                            } else {
                                dataSet.mode = .linear
                            }
                            dataSet.valueFormatter = formatter
                            
                            dataSet.circleRadius = 2
                            
                            dataSetNumber += 1
                            if dataSetNumber > colors.count {
                                dataSetNumber = 0
                            }
                            dataSets.append(dataSet)
                        }
                    }
                }
                self.setChart(dataSets: dataSets)
            }
        }
    }
    
    @IBAction func saveToCameraRoll(_ sender: Any) {
        // https://www.hackingwithswift.com/example-code/media/uiimagewritetosavedphotosalbum-how-to-write-to-the-ios-photo-album
        
        UIImageWriteToSavedPhotosAlbum(chartView.getChartImage(transparent: false)!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)

    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "The chart image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func createDataSetFromCensusValues(_ values: [CensusValue], label: String) -> LineChartDataSet {
        var entries: [ChartDataEntry] = []
        
        for value in values {
            let entry = ChartDataEntry(x: Double(value.year), y: value.value)
            entries.append(entry)
        }
        let dataSet = LineChartDataSet(values: entries, label: label)
        return dataSet
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
            if yPosition < view.frame.minY + 120 {
                yPosition = view.frame.minY + 120
            }
            
            var year = String(entry.x)
            let index = year.index(year.startIndex, offsetBy: 5)
            year = year.substring(to: index)
            if let fact = chartSpecs?.factY {
                if fact.unit! == "$" {
                    geoLabel.text = "\(dataSet.label!) had \(fact.unit!)\(entry.y) \(fact.factName!) in \(year)"
                } else {
                    geoLabel.text = "\(dataSet.label!) had \(entry.y)\(fact.unit!) \(fact.factName!) in \(year)"
                }
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
    
    func setChart(dataSets: [LineChartDataSet]) {
        chartView.noDataText = "You need to provide data for the chart."
        
        let data = LineChartData(dataSets: dataSets)
        chartView.data = data
        
        titleLabel.text = chartSpecs?.factY?.factDescription ?? ""
        
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
}
