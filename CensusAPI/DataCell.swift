//
//  DataCell.swift
//  CensusAPI
//
//  Created by Dean Copeland on 2/14/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit

class DataCell: UITableViewCell {

    var data = [String]() {
        didSet {
          //  print("didSet")
            updateUI()
        }
    }
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!

    
    private func updateUI() {
        if data.count >= 1 {
            label1.text = data[0]
        }
        if data.count >= 2 {
            label2.text = data[1]
        }
        if data.count >= 3 {
            label3.text = data[2]
        }
        if data.count >= 4 {
            label4.text = data[3]
        }
        /*
        if data.count >= 5 {
            label4.text = data[4]
        }
*/
        
    }
}
