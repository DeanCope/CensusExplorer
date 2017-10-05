//
//  StateCell.swift
//  CensusAPI
//
//  Created by Dean Copeland on 6/21/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit

class StateCell: UITableViewCell {

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
