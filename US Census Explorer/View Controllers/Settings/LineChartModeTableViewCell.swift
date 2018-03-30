//
//  LineChartModeTableViewCell.swift
//  CensusAPI
//
//  Created by Dean Copeland on 10/12/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit
import Charts

class LineChartModeTableViewCell: UITableViewCell {
    
    // MARK: - Type Properties
    
    static let reuseIdentifier = "LineChartModeCell"
    
    var viewModel: LineChartModeCellViewModel?
    
    // MARK: - Configuration
    
    func configure(withViewModel viewModel: LineChartModeCellViewModel) {
        self.viewModel = viewModel
        textLabel?.text = viewModel.text
        if viewModel.selected {
            accessoryType = .checkmark
        } else {
            accessoryType = .none
        }
    }
    
    // MARK: - Initialization
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

