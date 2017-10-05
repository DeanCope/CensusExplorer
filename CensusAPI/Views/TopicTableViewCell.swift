//
//  TopicTableViewCell.swift
//  CensusAPI
//
//  Created by Dean Copeland on 10/2/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit

class TopicTableViewCell: UITableViewCell {


    @IBOutlet private weak var topicNameLabel: UILabel!
    
    var topicName: String? {
        didSet {
            topicNameLabel.text = topicName
        }
    }

}
