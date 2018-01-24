//
//  SettingsTableViewController.swift
//  CensusAPI
//
//  Created by Dean Copeland on 9/14/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit
import Charts

class SettingsTableViewController: UITableViewController {

    @IBOutlet private weak var chartLineWidthSlider: UISlider!
    @IBOutlet private weak var chartLineWidthLabel: UILabel!
    @IBOutlet private weak var showValuesSwitch: UISwitch!
    
    @IBOutlet private weak var linearModeCell: LineChartModeTableViewCell!
    @IBOutlet private weak var horizontalModeCell: LineChartModeTableViewCell!
    @IBOutlet private weak var cubicModeCell: LineChartModeTableViewCell!
    @IBOutlet private weak var steppedModeCell: LineChartModeTableViewCell!
    
    var viewModel: SettingsViewModel? {
        didSet {
            updateView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func updateView() {
        if let viewModel = viewModel {
            updateSettingsView(withViewModel: viewModel)
            
        } else {
         //   messageLabel.isHidden = false
         //   messageLabel.text = "Unable to fetch settings data."
        }
    }
    
    private func updateSettingsView(withViewModel viewModel: SettingsViewModel) {
        // Set the values of the controls equal to the values from UserDefaults
        chartLineWidthSlider.value = viewModel.chartLineWidthFloat
        chartLineWidthLabel.text = viewModel.chartLineWidthString
        showValuesSwitch.setOn(viewModel.chartShowValues, animated: false)
        configureModeCells()
        
    }
    func configureModeCells() {
        if let viewModel = viewModel {
        linearModeCell.configure(withViewModel: LineChartModeCellViewModel(mode: .linear, viewModel: viewModel))
        horizontalModeCell.configure(withViewModel: LineChartModeCellViewModel(mode: .horizontalBezier, viewModel: viewModel))
        cubicModeCell.configure(withViewModel: LineChartModeCellViewModel(mode: .cubicBezier, viewModel: viewModel))
        steppedModeCell.configure(withViewModel: LineChartModeCellViewModel(mode: .stepped, viewModel: viewModel))
        }
    }

    @IBAction func setChartLineWidth(_ sender: Any) {
        UserDefaults.setChartLineWidth(chartLineWidthSlider.value)
        chartLineWidthLabel.text = viewModel?.chartLineWidthString
    }
    
    @IBAction func setShowValues(_ sender: Any) {
        UserDefaults.setChartShowValues(showValuesSwitch.isOn)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? LineChartModeTableViewCell {
            if let mode = cell.viewModel?.mode {
                UserDefaults.setLineChartMode(mode)
                configureModeCells()
            }
        }
    }
}
