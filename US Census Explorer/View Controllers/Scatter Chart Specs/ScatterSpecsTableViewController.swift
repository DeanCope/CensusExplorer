//
//  ScatterSpecsTableViewController.swift
//  CensusAPI
//
//  Created by Dean Copeland on 9/29/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit
import RxSwift

// This class is responsible for displaying the view for the user to choose
// the X and Y topics and Year for the scatter chart.
// It uses a static UITableView (which is why it is a UITableViewController subclass)
class ScatterSpecsTableViewController: UITableViewController, StoryboardInitializable {

    private let disposeBag = DisposeBag()
    
    var viewModel: ScatterSpecsViewModel!
    
    @IBOutlet private weak var factXNameLabel: UILabel!
    @IBOutlet private weak var factYNameLabel: UILabel!
    @IBOutlet private weak var yearLabel: UILabel!
    @IBOutlet private weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupUI()
        
        bindViewModel()
    }
    
    private func setupUI() {
     
        /*
        let headerCell = tableView.dequeueReusableCell(withIdentifier: HeaderTableViewCell.Identifier) as! HeaderTableViewCell
        headerCell.sectionName = viewModel.headerCellSectionName
        tableView.tableHeaderView = headerCell
 
 */
    }
    
    private func bindViewModel() {
        
        viewModel.factXString
            .drive(factXNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.factYString
            .drive(factYNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.yearString
            .drive(yearLabel.rx.text)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .map { [unowned self] indexPath in
                let cell = self.tableView.cellForRow(at: indexPath)
                switch cell?.reuseIdentifier {
                case "TopicX"?:
                    return ScatterSpecsCoordinator.ScatterSpecItem.topicX
                case "TopicY"?:
                    return ScatterSpecsCoordinator.ScatterSpecItem.topicY
                case "Year"?:
                    return ScatterSpecsCoordinator.ScatterSpecItem.year
                default:
                    return ScatterSpecsCoordinator.ScatterSpecItem.year  //???
                }
            }
            .bind(to: viewModel.selectItem)
            .disposed(by: disposeBag)
        
        continueButton.rx.tap
            .bind(to: viewModel.chooseContinue)
            .disposed(by: disposeBag)
        
        /*
        tableView.rx.itemAccessoryButtonTapped
            .subscribe(onNext: { [unowned self] indexPath in
                let fact = self.viewModel.factAtIndexPath(indexPath)
                self.alert(title: fact.factName!, message: fact.factDescription)
            })
            .disposed(by: disposeBag)
 */
        
    }
    /*
    private func openYearsList() {
        performSegue(withIdentifier: Storyboard.chooseYearSegueId, sender: self)
    }
 */
    
    /*
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        factXNameLabel.text = chartSpecs?.factX?.factName ?? "Select a topic..."
        factYNameLabel.text = chartSpecs?.factY?.factName ?? "Select a topic..."
        yearLabel.text = chartSpecs?.yearString ?? UserDefaults.defaultYearString
        
        if chartSpecs?.factX == nil || chartSpecs?.factY == nil {
                continueButton.isEnabled = false
        } else {
            continueButton.isEnabled = true
        }
        
        //print("RxSwift resources: \(RxSwift.Resources.total)")
    }
 */
    
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case Storyboard.chooseXAxisTopicSegueId?:
            break
            /*
            let nextViewController = segue.destination as! ScatterTopicsViewController
            // Configure the target view controller with the chart specs
            nextViewController.chartSpecs = chartSpecs
            nextViewController.axis = .x
 */
         //   nextViewController.chartSpecsDelegate = self
        case Storyboard.chooseYAxisTopicSegueId?:
            break
            /*
            let nextViewController = segue.destination as! ScatterTopicsViewController
            // Configure the target view controller with the chart specs
            nextViewController.chartSpecs = chartSpecs
            nextViewController.axis = .y
 */
         //   nextViewController.chartSpecsDelegate = self
        case Storyboard.chooseYearSegueId?:
            let nextViewController = segue.destination as! YearsTableViewController
            
            nextViewController.selectedYear
                .subscribe(
                    onNext: { [weak self] newYear in
                    self?.chartSpecs?.year = Int16(newYear)
                        },onDisposed: {
                        print("completed year selection")
                    })
                .disposed(by: nextViewController.disposeBag)
 
            // Configure the target view controller with the chart specs
            nextViewController.chartSpecs = chartSpecs
            //nextViewController.chartSpecsDelegate = self
        case Storyboard.chooseGeosSegueId?:
            let nextViewController = segue.destination as! GeosViewController
            // Configure the target view controller with the chart specs
            //nextViewController.chartSpecs = chartSpecs
        default: break
        }
    }
 */
    
    /*
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if indexPath.section == 1 {
            // X Axis
            if let fact = chartSpecs?.factX {
                alert(title: fact.factName!, message: fact.factDescription!)
            } else {
                alert(title: "Choose a topic", message: "Choose a topic for the X Axis of the Scatter chart.")
            }
        } else {
            // Y Axis
            if let fact = chartSpecs?.factY {
                alert(title: fact.factName!, message: fact.factDescription!)
            } else {
                alert(title: "Choose a topic", message: "Choose a topic for the Y Axis of the Scatter chart.")
            }
        }
    }
 */
    
    @IBAction func unwindToScatterSpecs(segue:UIStoryboardSegue) {
        
    }

    @IBAction func continueTouched(_ sender: Any) {
        
    }
}
