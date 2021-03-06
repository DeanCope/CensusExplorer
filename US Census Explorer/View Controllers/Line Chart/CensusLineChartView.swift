//
//  CensusLineChartView.swift
//  CensusAPI
//
//  Created by Dean Copeland on 10/17/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import Charts
import RxSwift
// This class builds upon the base Line Chart View, adding some additional features:
// 1. The ability to configure the chart view from a provided view model
// 2. The ability to add a (rotated text) Y axis label
// 3. Handling of a dynamically positioned popup label that provides details about a data point that the user taps
class CensusLineChartView: LineChartView {
    
    var popupLabel = InsetLabel()
    var viewModel: LineChartViewModel?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet private weak var xAxisLabel: UILabel!
    @IBOutlet private weak var yAxisLabelFrame: UIView!
    
    public var xAxisText = "" {
        didSet {
            xAxisLabel.text = xAxisText
        }
    }
    
    func configure(withViewModel viewModel: LineChartViewModel?) {
        guard let viewModel = viewModel else { return }
        self.viewModel = viewModel
        
        delegate = self
        
        if let chartData = viewModel.chartData {
            self.data = chartData
        }
        
        chartDescription?.enabled = true
        chartDescription?.text = "Source: US Census Bureau"
        
        if viewModel.shouldDisplayLegend {
            legend.enabled = true
            legend.drawInside = true
            legend.verticalAlignment = Legend.VerticalAlignment.top
        } else {
            legend.enabled = false
        }
        xAxis.labelPosition = .bottom
        xAxis.granularity = 1
        backgroundColor = viewModel.chartBackgroundColor
        animate(xAxisDuration: 0.5, yAxisDuration: 0.0)
        
        addYAxisLabel(viewModel.yAxisText)
    }
    
    private func addYAxisLabel(_ text: String) {
        
        let yAxisLabel: UILabel = UILabel()
        
        yAxisLabel.frame = CGRect(x: 2, y: frame.maxY / 2, width: 10, height: 300)
        yAxisLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        yAxisLabel.textAlignment = .center
        yAxisLabel.text = text
        yAxisLabel.numberOfLines=1
        yAxisLabel.font=UIFont.systemFont(ofSize: 12)
        addSubview(yAxisLabel)
        yAxisLabel.translatesAutoresizingMaskIntoConstraints = false
        yAxisLabel.centerXAnchor.constraint(equalTo: yAxisLabelFrame.centerXAnchor).isActive = true
        yAxisLabel.centerYAnchor.constraint(equalTo: yAxisLabelFrame.centerYAnchor).isActive = true
    }
    
}

// MARK: - Chart View Delegate

extension CensusLineChartView: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        guard let dataSet = chartView.data?.dataSets[highlight.dataSetIndex] else { return }
        
        popupLabel = InsetLabel()
        popupLabel.layer.borderColor = dataSet.color(atIndex: 0).cgColor
        popupLabel.backgroundColor = viewModel?.chartBackgroundColor
        popupLabel.layer.borderWidth = 1.0
        popupLabel.layer.cornerRadius = 8
        popupLabel.numberOfLines = 0
        popupLabel.lineBreakMode = .byWordWrapping
        
        // Dynamically position the label
        var xPosition = min(highlight.xPx, frame.maxX - 95)
        xPosition = max(xPosition, frame.minX + 95)
        var yPosition = min(highlight.yPx, frame.maxY - 40)
        yPosition = max(yPosition, frame.minY + 40)
        
        let dotView = UIView(frame: CGRect(origin: CGPoint(x: xPosition, y: yPosition), size: CGSize(width: 1, height: 1)))
        addSubview(dotView)
        
        var year = String(entry.x)
        let index = year.index(year.startIndex, offsetBy: 5)
        year = String(year[..<index])
        if let fact = viewModel?.chartSpecs.factY.value {
            if fact.unit! == "$" {
                popupLabel.text = "\(dataSet.label!) had \(fact.unit!)\(entry.y) \(fact.factName!) in \(year)"
            } else {
                popupLabel.text = "\(dataSet.label!) had \(entry.y)\(fact.unit!) \(fact.factName!) in \(year)"
            }
        }
        popupLabel.translatesAutoresizingMaskIntoConstraints = false
        popupLabel.widthAnchor.constraint(equalToConstant: 150.0).isActive = true
        
        popupLabel.leftInset = 3
        popupLabel.rightInset = 3
        
        popupLabel.tag = 100
        if let previousPopupView = viewWithTag(100) {
            previousPopupView.removeFromSuperview()
        }
        addSubview(popupLabel)
        
        popupLabel.centerXAnchor.constraint(equalTo: dotView.centerXAnchor).isActive = true
        popupLabel.centerYAnchor.constraint(equalTo: dotView.centerYAnchor).isActive = true
    }

    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        popupLabel.text = ""
        if let previousPopupView = viewWithTag(100) {
            previousPopupView.removeFromSuperview()
        }
    }
}
