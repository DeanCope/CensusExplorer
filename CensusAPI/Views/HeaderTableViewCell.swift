//
//  HeaderTableViewCell.swift
//  CensusAPI
//
//  Created by Dean Copeland on 10/3/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit

class HeaderTableViewCell: UITableViewCell {

    @IBOutlet private weak var sectionNameLabel: UILabel!
    
    var sectionName: String? {
        didSet {
            sectionNameLabel.text = sectionName
        }
    }
    

}
