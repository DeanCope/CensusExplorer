//
//  SettingsTableViewController.swift
//  CensusAPI
//
//  Created by Dean Copeland on 9/14/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit
import Charts
import RxSwift

class SettingsTableViewController: UITableViewController {
    
    let disposeBag = DisposeBag()

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
            bindViewModel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func bindViewModel() {
        
        guard let viewModel = viewModel else {return}
        // Inputs from ViewModel to UI
        viewModel.alertMessage
            .subscribe(onNext: { [weak self] title, message in self?.alert(title: title, message: message) })
            .disposed(by: disposeBag)
        
        viewModel.chartLineWidthStringDriver
            .drive(chartLineWidthLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Outputs from UI to ViewModel
        chartLineWidthSlider.rx.value
            .bind(to: viewModel.setChartLineWidth)
            .disposed(by: disposeBag)
        
        showValuesSwitch.rx.isOn
            .bind(to: viewModel.setChartShowValues)
            .disposed(by: disposeBag)
    }
    
    private func updateView() {
        guard let viewModel = viewModel else {return}
        
        // Set the values of the controls equal to the values from the ViewModel
        chartLineWidthSlider.value = viewModel.chartLineWidthFloat
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? LineChartModeTableViewCell {
            if let mode = cell.viewModel?.mode {
                viewModel?.setLineChartMode
                    .onNext(mode)
                configureModeCells()
            }
        }
    }
}
