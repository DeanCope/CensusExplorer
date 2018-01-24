//
//  YearsTableViewController.swift
//  CensusAPI
//
//  Created by Dean Copeland on 9/29/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit
import RxSwift

// This class is responsible for displaying a choice of years for the user to select from.
// The selected year is posted to an RxSwift PublishSubject so subscriber(s) can know
// what year was selected
class YearsTableViewController: UITableViewController, StoryboardInitializable {
    
    private let disposeBag = DisposeBag()
    
    var viewModel: YearsViewModel!
    
    // MARK: public properties
    
    var selectedYear: Observable<Int16> {
        return selectedYearSubject.asObservable()
    }
    
    // MARK: private properties
    
    fileprivate let selectedYearSubject = PublishSubject<Int16>()
    
   // var chartSpecs: ChartSpecs?
    
   //var chartSpecsDelegate: SettableChartSpecs?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        bindViewModel()
    }
    
    private func setupUI() {
        
        tableView.dataSource = viewModel.yearsDataSource
        
    }
    
    private func bindViewModel() {
        tableView.rx.itemSelected
            .map { [unowned self] indexPath in
                return self.viewModel.yearAtIndexPath(indexPath)
            }
            .bind(to: viewModel.chooseYear)
            .disposed(by: disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Complete the selected year publish subject sequence
        selectedYearSubject.onCompleted()
    }
    
    
    // MARK: - TableView delegate
    /*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            
            if let year = Int16((cell.textLabel?.text)!) {
                
                chartSpecs?.year = year
                
                // post the selected year to the selected year publish subject sequence
                selectedYearSubject.onNext(year)
                
                // Pass the chart specs back to the delegate (previous view controller)
               // chartSpecsDelegate!.chartSpecs = chartSpecs
                
                performSegue(withIdentifier: Storyboard.unwindSegueToScatterSpecs, sender: self)
            }
        }
    }
 */
}



