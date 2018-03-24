//
//  GeosViewController.swift
//  CensusAPI
//
//  Created by Dean Copeland on 6/6/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

// This class is responsible for displaying the grouped, multiple-select list of geographies (USA + States)
// for the user to choose from.
// It is used by both the Line Chart and Scatter Chart.
// The results of the user selection(s) are stored in Core Data, using the "selected" flag on each Geo.
    
class GeosViewController: UIViewController, UITableViewDelegate, StoryboardInitializable {
    
    let disposeBag = DisposeBag()
    
    var viewModel: GeosViewModel!
    
    @IBOutlet private weak var instructionsLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var graphItButton: UIBarButtonItem!
    @IBOutlet private weak var selectAllButton: UIButton!
    @IBOutlet private weak var deselectAllButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Source: https://stackoverflow.com/questions/47754472/ios-uinavigationbar-button-remains-faded-after-segue-back/47839657#47839657
        self.navigationController?.navigationBar.tintAdjustmentMode = .normal
        self.navigationController?.navigationBar.tintAdjustmentMode = .automatic
    }
    
    private func setupUI() {
        
        tableView.dataSource = viewModel.geosDataSource
        
        self.instructionsLabel.text = "Choose the whole country and/or one or more states."
        
    }
    
    private func bindViewModel() {
        
        // Inputs
        viewModel.alertMessage
            .subscribe(onNext: { [weak self] in self?.alert(title: $0, message: $1) })
            .disposed(by: disposeBag)
        
        viewModel.title
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        viewModel.dataChanged
            .subscribe(onNext: { [weak self] in self?.tableView.reloadData()
                })
            .disposed(by: disposeBag)
        
        viewModel.querying
            .drive(onNext: { [weak self] querying in
                self?.graphItButton.isEnabled = !querying
                }
            )
            .disposed(by: disposeBag)
        
        graphItButton.rx.tap
           // .throttle(0.5, scheduler: MainScheduler.instance)
            .bind(to: viewModel.graphIt)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .map { [unowned self] indexPath in
                if let cell = self.tableView.cellForRow(at: indexPath) as? StateCell {
                    cell.accessoryType = .checkmark
                }
                return self.viewModel.geoAtIndexPath(indexPath)
            }
            .bind(to: viewModel.selectGeo)
            .disposed(by: disposeBag)
        
        tableView.rx.itemDeselected
            .map { [unowned self] indexPath in
                if let cell = self.tableView.cellForRow(at: indexPath) as? StateCell {
                    cell.accessoryType = .none
                }
                return self.viewModel.geoAtIndexPath(indexPath)
            }
            .bind(to: viewModel.deselectGeo)
            .disposed(by: disposeBag)
        
        selectAllButton.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .bind(to: viewModel.selectAll)
            .disposed(by: disposeBag)
        
        deselectAllButton.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .bind(to: viewModel.deselectAll)
            .disposed(by: disposeBag)
    }
    
}
