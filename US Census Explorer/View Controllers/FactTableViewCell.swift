//
//  FactTableViewCell.swift
//  CensusAPI
//
//  Created by Dean Copeland on 10/2/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit

class FactTableViewCell: UITableViewCell {

    static let Identifier = "FactTableViewCell"

    @IBOutlet private weak var factNameLabel: UILabel!
    
    var factName: String? {
        didSet {
            factNameLabel.text = factName
        }
    }
}
