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
    
    // Observe gotCensusValues so we can enable the GraphIt button when the values are available.
    var gotCensusValuesObserver: Any?
    
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
    
    private func setupUI() {
        
        tableView.dataSource = viewModel.geosDataSource
        
        self.instructionsLabel.text = "Choose the whole country and/or one or more states."
        
    }
    
    private func bindViewModel() {
        
        // Title
        viewModel.title
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        viewModel.alertMessage
            .subscribe(onNext: { [weak self] in self?.alert(message: $0) })
            .disposed(by: disposeBag)
        
        viewModel.dataChanged
            .subscribe(onNext: { [weak self] in self?.tableView.reloadData()
                })
            .disposed(by: disposeBag)
        
        graphItButton.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Only enable the GraphIt button if we have already received the census values from the server
        if CensusDataSource.sharedInstance.gotCensusValues {
            graphItButton.isEnabled = true
        } else {
            graphItButton.isEnabled = false
        /*    gotCensusValuesObserver = startObserving(notificationName: NotificationNames.GotCensusValues) {notification in
                self.graphItButton.isEnabled = true
            }
 */
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
       // stopObservingNotification(observer: gotCensusValuesObserver)
    }
    
    
    /*
    @IBAction func deselectAllRows(_ sender: Any) {
        CensusDataSource.sharedInstance.selectAllGeographies(false){ (success, error) in
            if success {
                self.tableView.reloadData()
            } else {
                var message = "Error selecting all rows"
                if let error = error {
                    message = message + ": \(error.localizedDescription)"
                }
                self.alert(message: message)
            }
        }
    }
 
    @IBAction func selectAllRows(_ sender: Any) {
        CensusDataSource.sharedInstance.selectAllGeographies(true){ (success, error) in
            if success {
                self.tableView.reloadData()
            } else {
                var message = "Error selecting all rows"
                if let error = error {
                    message = message + ": \(error.localizedDescription)"
                }
                self.alert(message: message)
            }
        }
    }
 */
    /*
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections
        guard let sections = fetchedResultsController.sections else {
            alert(message: "No sections were found in the data.")
            return 0
        }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            self.alert(message: "Unexpected Section")
            return "Unexpected Section"
        }
        guard let name = CensusClient.GeoLevels[sectionInfo.name] else {
            self.alert(message: "Unexpected geo level found: \(sectionInfo.name)")
            return "Unexpected geo level"
        }
        return name
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            self.alert(message: "Unexpected section number found: \(section)")
            fatalError("Unexpected Section number: \(section)")
        }
        return sectionInfo.numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StateCell.Identifier, for: indexPath)
        
        // Fetch State
        let state = fetchedResultsController.object(at: indexPath)
        
        // Configure Cell
        if let stateCell = cell as? StateCell {
            stateCell.state = state
        }
        
        if state.isSelected {
            cell.accessoryType = .checkmark
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.bottom)
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
 */
    
}
/*
    // MARK: - TableViewDelegate
extension GeosViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? StateCell {
            cell.accessoryType = .checkmark
            cell.state?.isSelected = true
            stack!.save()
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? StateCell {
            cell.accessoryType = .none
            cell.state?.isSelected = false
            stack!.save()
        }
    }
}
 */
