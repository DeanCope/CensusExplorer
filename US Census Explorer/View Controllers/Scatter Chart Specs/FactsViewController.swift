//
//  FactsViewController.swift
//  CensusAPI
//
//  Created by Dean Copeland on 9/29/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FactsViewController: UIViewController, StoryboardInitializable {
    
    let disposeBag = DisposeBag()
    
    var viewModel: FactsViewModel!
    
    @IBOutlet private weak var tableView: UITableView!
    
    //weak var chartSpecsDelegate: SettableChartSpecs?
    
    public var chartSpecs: ChartSpecs? {
        didSet {
    //        factsDataSource.chartSpecs = chartSpecs
        }
    }
    
    //var axis: Axis? {
    //    didSet {
    //        factsDataSource.axis = axis
    //    }
    //}

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        bindViewModel()
        
    }
    
    private func setupUI() {
        tableView.dataSource = viewModel.factsDataSource
        
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "HeaderTableViewCell") as! HeaderTableViewCell
        if viewModel.axis == .x {
            headerCell.sectionName = "Select a topic for the X axis."
        } else {
            headerCell.sectionName = "Select a topic for the Y axis."
        }
        tableView.tableHeaderView = headerCell
        
    }
    
    private func bindViewModel() {
        viewModel.alertMessage
            .subscribe(onNext: { [weak self] title, message in self?.alert(title: title, message: message) })
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .map { [unowned self] indexPath in
                if let cell = self.tableView.cellForRow(at: indexPath) as? FactTableViewCell {
                    cell.accessoryType = .checkmark
                }
                return self.viewModel.factAtIndexPath(indexPath)
            }
            .bind(to: viewModel.chooseFact)
            .disposed(by: disposeBag)
        
        tableView.rx.itemAccessoryButtonTapped
            .subscribe(onNext: { [unowned self] indexPath in
                let fact = self.viewModel.factAtIndexPath(indexPath)
                self.alert(title: fact.factName!, message: fact.factDescription)
            })
            .disposed(by: disposeBag)
        
    }
}

// MARK: - Extension - UITableViewDelegate
extension FactsViewController: UITableViewDelegate {
    
    
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        let fact = factsDataSource.getFact(at: indexPath)
        
        chartSpecs?.setFact(fact, forAxis: axis!)
        
        // Pass the chart specs back to the delegate (previous view controller)
       // chartSpecsDelegate!.chartSpecs = chartSpecs
        
        performSegue(withIdentifier: Storyboard.unwindSegueToScatterSpecs, sender: self)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
 */
    /*
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let fact = factsDataSource.getFact(at: indexPath)
        alert(title: fact.factName!, message: fact.factDescription)
    }
 */
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 27
    }
}
