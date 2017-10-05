//
//  SettingsTableViewController.swift
//  CensusAPI
//
//  Created by Dean Copeland on 9/14/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var chartLineWidthSlider: UISlider!
    
    @IBOutlet weak var chartLineWidthLabel: UILabel!
    
    @IBOutlet weak var smoothingSwitch: UISwitch!
    
    @IBOutlet weak var showValuesSwitch: UISwitch!
    
    let numberFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 1
        return nf
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the values of the controls equal to the values from UserDefaults
        chartLineWidthSlider.value = Float(UserDefaults.standard.float(forKey: UserDefaults.Keys.ChartLineWidth))
        chartLineWidthLabel.text = numberFormatter.string(for: chartLineWidthSlider.value)
        smoothingSwitch.setOn(UserDefaults.standard.bool(forKey: UserDefaults.Keys.ChartCubicSmoothing), animated: false)
        showValuesSwitch.setOn(UserDefaults.standard.bool(forKey: UserDefaults.Keys.ChartShowValues), animated: false)
    }

    @IBAction func setChartLineWidth(_ sender: Any) {
        UserDefaults.standard.set(chartLineWidthSlider.value, forKey: UserDefaults.Keys.ChartLineWidth)
        chartLineWidthLabel.text = numberFormatter.string(for: chartLineWidthSlider.value)
    }

    @IBAction func setSmoothing(_ sender: Any) {
        UserDefaults.standard.set(smoothingSwitch.isOn, forKey: UserDefaults.Keys.ChartCubicSmoothing)
    }
    
    @IBAction func setShowValues(_ sender: Any) {
        UserDefaults.standard.set(showValuesSwitch.isOn, forKey: UserDefaults.Keys.ChartShowValues)
        
    }
}