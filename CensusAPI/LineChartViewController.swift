//
//  LineChartViewController.swift
//  CensusAPI
//
//  Created by Dean Copeland on 6/23/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//
import UIKit
import Charts
import CoreData

class LineChartViewController: UIViewController, ChartViewDelegate {

    @IBOutlet weak var lineChartView: LineChartView!
    
    @IBOutlet weak var geoLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chartAndTitleView: UIView!
    var fact: CensusFact? = nil
    
    let largeNumber = 31908551587
    let numberFormatter = NumberFormatter()
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        lineChartView.delegate = self
        geoLabel.isHidden = true
        geoLabel.translatesAutoresizingMaskIntoConstraints = true
        
        
        
        //numberFormatter.   //.style = .decimal  //.numberStyle = //.decimal
        //let formattedNumber = numberFormatter.string(from: NSNumber(value:largeNumber))
        
        /*
        let marker: BalloonMarker = BalloonMarker(color: UIColor.black, font: UIFont(name: "Helvetica", size: 12)!, textColor: UIColor.white, insets: UIEdgeInsets(top: 7.0, left: 7.0, bottom: 7.0, right: 7.0))
        marker.minimumSize = CGSize(width: 75.0, height: 35.0)
        lineChartView.marker = marker
        */
    }
    
    override func viewWillAppear(_ animated: Bool) {

        self.refresh(self)
    }
    
    @IBAction func refresh(_ sender: Any) {
        
        var formatter = CensusValueFormatter()
        
        if let _ = fact {
            let colors = [UIColor.red, .green, .blue, .black, .brown, .cyan, .gray ]
            numberFormatter.numberStyle = .decimal
            CensusDataSource.sharedInstance().getSelectedGeographies() { (geographies, error) in
                if let _ = geographies {
                    var dataSets: [LineChartDataSet] = []
                    var dataSetNumber = 0
                    for geography in geographies! {
                        CensusDataSource.sharedInstance().getDataFromDB(forFact: self.fact!, geography: geography) {
                            (result, error) in
                            if let _ = result {
                                let dataSet = self.createDataSetFromCensusValues(result!, label: geography.name!)
                                dataSet.colors = ChartColorTemplates.colorful()
                                if dataSetNumber < colors.count {
                                    dataSet.setColor(colors[dataSetNumber])
                                    dataSet.setCircleColor(colors[dataSetNumber])
                                }
                                
                                dataSet.lineWidth = CGFloat(UserDefaults.standard.float(forKey: Defaults.ChartLineWidthKey))
                                dataSet.drawValuesEnabled = UserDefaults.standard.bool(forKey: Defaults.ChartShowValuesKey)
                                if UserDefaults.standard.bool(forKey: Defaults.ChartCubicSmoothingKey) {
                                    dataSet.mode = .cubicBezier
                                } else {
                                    dataSet.mode = .linear
                                }
                                dataSet.valueFormatter = formatter
                                
                                dataSet.circleRadius = 2
                                //dataSet.drawValuesEnabled = false
                                
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
    }
    
    @IBAction func saveToCameraRoll(_ sender: Any) {
        // https://www.hackingwithswift.com/example-code/media/uiimagewritetosavedphotosalbum-how-to-write-to-the-ios-photo-album
        
        UIImageWriteToSavedPhotosAlbum(lineChartView.getChartImage(transparent: false)!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)

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
        
        if let dataSet = lineChartView.data?.dataSets[highlight.dataSetIndex] {
            
           //print("x: \(highlight.xPx), y: \(highlight.yPx)")
            
            //geoLabel.textColor = dataSet.color(atIndex: 0)
            geoLabel.layer.borderColor = dataSet.color(atIndex: 0).cgColor
            geoLabel.layer.borderWidth = 1.0
            geoLabel.layer.cornerRadius = 8
            
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
            //print ("max X: \(view.frame.maxX)")
            
            var year = String(entry.x)
            let index = year.index(year.startIndex, offsetBy: 5)
            year = year.substring(to: index)
            if fact!.unit! == "$" {
                geoLabel.text = "\(dataSet.label!) had \(fact!.unit!)\(entry.y) \(fact!.factName!) in \(year)"
            } else {
                geoLabel.text = "\(dataSet.label!) had \(entry.y)\(fact!.unit!) \(fact!.factName!) in \(year)"
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
        lineChartView.noDataText = "You need to provide data for the chart."
        
        let data = LineChartData(dataSets: dataSets)
        lineChartView.data = data
        
        titleLabel.text = fact?.factDescription
        
        lineChartView.chartDescription?.enabled = true
        lineChartView.chartDescription?.text = "Source: US Census Bureau"
        if dataSets.count < 11 {
        lineChartView.legend.enabled = true
        lineChartView.legend.drawInside = true
        lineChartView.legend.verticalAlignment = Legend.VerticalAlignment.top
        } else {
            lineChartView.legend.enabled = false
        }
        lineChartView.xAxis.labelPosition = .bottom
        
        //lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:years)
        lineChartView.xAxis.granularity = 1
        
        //lineChartView.leftAxis.axisMinimum = 0
        //.customAxisMin = 0
        
        lineChartView.backgroundColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)
        
        lineChartView.animate(xAxisDuration: 1.0, yAxisDuration: 0.0)
        
    }

}
