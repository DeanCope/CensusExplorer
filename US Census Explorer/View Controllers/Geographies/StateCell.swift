//
//  StateCell.swift
//  CensusAPI
//
//  Created by Dean Copeland on 6/21/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit

// This class is used by the GeosViewController to display a country or state as a table view cell.
class StateCell: UITableViewCell {

    static let Identifier = "StateCell"
    
    @IBOutlet weak var stateName: UILabel!
    
    var state: Geography? = nil {
        didSet {
            updateUI()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func updateUI() {
        stateName.text = state?.name
    }
}
