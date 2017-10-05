//
//  ScatterTopicsViewController.swift
//  CensusAPI
//
//  Created by Dean Copeland on 9/29/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit

class ScatterTopicsViewController: UIViewController, SettableChartSpecs {

    fileprivate struct Storyboard {
        static let unwindSegueToScatterSpecs = "UnwindSegueToScatterSpecs"
    }
    
    fileprivate var factsDataSource = FactsDataSource()
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var chartSpecsDelegate: SettableChartSpecs?
    
    public var chartSpecs: ChartSpecs? {
        didSet {
            factsDataSource.chartSpecs = chartSpecs
        }
    }
    
    var axis: Axis? {
        didSet {
            factsDataSource.axis = axis
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = factsDataSource
        
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "HeaderTableViewCell") as! HeaderTableViewCell
        if axis == .x {
            headerCell.sectionName = "Select a topic for the X axis."
        } else {
            headerCell.sectionName = "Select a topic for the Y axis."
        }
        tableView.tableHeaderView = headerCell
        
    }
}

// MARK: - Extension - UITableViewDelegate
extension ScatterTopicsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        let fact = factsDataSource.getFact(at: indexPath)
        
        chartSpecs?.setFact(fact, forAxis: axis!)
        
        // Pass the chart specs back to the delegate (previous view controller)
        chartSpecsDelegate!.chartSpecs = chartSpecs
        
        performSegue(withIdentifier: Storyboard.unwindSegueToScatterSpecs, sender: self)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let fact = factsDataSource.getFact(at: indexPath)
        alert(title: fact.factName!, message: fact.factDescription)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 27
    }
}
