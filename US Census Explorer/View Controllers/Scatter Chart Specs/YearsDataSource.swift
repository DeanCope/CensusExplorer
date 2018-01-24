//
//  YearsDataSource.swift
//  CensusAPI
//
//  Created by Dean Copeland on 1/17/18.
//  Copyright © 2018 Dean Copeland. All rights reserved.
//

import UIKit

class YearsDataSource: NSObject, UITableViewDataSource {
    
    let currentlySelectedYear: Int16?
    
    init(currentlySelectedYear: Int16?) {
        self.currentlySelectedYear = currentlySelectedYear
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CensusClient.Years.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: YearTableViewCell.Identifier, for: indexPath) as? YearTableViewCell else {
            fatalError("Could not dequeue YearCell")
        }
        cell.textLabel?.text = CensusClient.Years[indexPath.row]
        if let specYear = currentlySelectedYear {
            if Int16(CensusClient.Years[indexPath.row]) == specYear {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        return cell
    }
    
    func getYear(at indexPath: IndexPath) -> Int16 {
        return Int16(CensusClient.Years[indexPath.row])!
    }
}
