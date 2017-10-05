//
//  ScatterSpecsTableViewController.swift
//  CensusAPI
//
//  Created by Dean Copeland on 9/29/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit

class ScatterSpecsTableViewController: UITableViewController, SettableChartSpecs {

    private struct Storyboard {
        static let chooseXAxisTopicSegueId = "ChooseXAxisTopic"
        static let chooseYAxisTopicSegueId = "ChooseYAxisTopic"
        static let chooseYearSegueId = "ChooseYear"
        static let chooseGeosSegueId = "ChooseGeos"
    }
    
    var chartSpecs: ChartSpecs?
    
    @IBOutlet weak var factXNameLabel: UILabel!
    
    @IBOutlet weak var factYNameLabel: UILabel!
    
    @IBOutlet weak var yearLabel: UILabel!
    
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chartSpecs = ChartSpecs(chartType: .scatter, factX: nil, factY: nil, year: 2015)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        factXNameLabel.text = chartSpecs?.factX?.factName ?? "Select a topic..."
        factYNameLabel.text = chartSpecs?.factY?.factName ?? "Select a topic..."
        
        if chartSpecs?.factX == nil || chartSpecs?.factY == nil {
                continueButton.isEnabled = false
        } else {
            continueButton.isEnabled = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case Storyboard.chooseXAxisTopicSegueId?:
            let nextViewController = segue.destination as! ScatterTopicsViewController
            // Configure the target view controller with the chart specs
            nextViewController.chartSpecs = chartSpecs
            nextViewController.axis = .x
            nextViewController.chartSpecsDelegate = self
        case Storyboard.chooseYAxisTopicSegueId?:
            let nextViewController = segue.destination as! ScatterTopicsViewController
            // Configure the target view controller with the chart specs
            nextViewController.chartSpecs = chartSpecs
            nextViewController.axis = .y
            nextViewController.chartSpecsDelegate = self
        case Storyboard.chooseYearSegueId?:
            let nextViewController = segue.destination as! YearsTableViewController
            // Configure the target view controller with the chart specs
            nextViewController.chartSpecs = chartSpecs
            nextViewController.chartSpecsDelegate = self
        case Storyboard.chooseGeosSegueId?:
            let nextViewController = segue.destination as! GeosViewController
            // Configure the target view controller with the chart specs
            nextViewController.chartSpecs = chartSpecs
          //  nextViewController.chartSpecsDelegate = self
        default: break
        }
        
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        //let fact = facts[indexPath.row]
       // alert(title: fact.factName!, message: fact.factDescription)
        if indexPath.section == 1 {
            // X Axis
            if let fact = chartSpecs?.factX {
                alert(title: fact.factName!, message: fact.factDescription!)
            }
        } else {
            // Y Axis
            if let fact = chartSpecs?.factY {
                alert(title: fact.factName!, message: fact.factDescription!)
            }
        }
    }
    
    @IBAction func unwindToScatterSpecs(segue:UIStoryboardSegue) {
        
    }

    @IBAction func continueTouched(_ sender: Any) {
        
    }
}
