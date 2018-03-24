//
//  LineSpecsViewController.swift
//  CensusAPI
//
//  Created by Dean Copeland on 8/29/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

// This class is responsible for displaying the first (functional) view that the user sees.
// It displays a list of census topics for the user to choose from.
// If the census data has not yet been retrieved, the CensusDataSource is used
// to get the data from the Census server.
// The user also has the option to refresh the census data.

class LineSpecsViewController: UIViewController, StoryboardInitializable {
    
    let disposeBag = DisposeBag()
    
    var viewModel: LineSpecsViewModel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reloadDataButton: UIButton!
    @IBOutlet weak var progressView: ProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        bindViewModel()
    }
    
    private func setupUI() {
        
        tableView.dataSource = viewModel.factsDataSource
        
        let headerCell = tableView.dequeueReusableCell(withIdentifier: HeaderTableViewCell.Identifier) as! HeaderTableViewCell
        headerCell.sectionName = viewModel.headerCellSectionName
        tableView.tableHeaderView = headerCell
    }
    
    private func bindViewModel() {
        
        // Inputs
        viewModel.alertMessage
            .subscribe(onNext: { [weak self] title, message in self?.alert(title: title, message: message) })
            .disposed(by: disposeBag)
        
        viewModel.querying
            .drive(onNext: { [weak self] querying in
                self?.progressView.isHidden = !querying
                self?.reloadDataButton.isEnabled = !querying
                self?.tableView.allowsSelection = !querying
                }
            )
            .disposed(by: disposeBag)
        
        viewModel.querying
            .drive(progressView.rx.animate)
            .disposed(by: disposeBag)

         viewModel.queryProgress
            .drive(progressView.rx.progress)
            .disposed(by: disposeBag)
        
        viewModel.progressMessage
            .drive(progressView.rx.labelText)
            .disposed(by: disposeBag)

        viewModel.queryCompletion
            .drive (onNext: {[weak self] success, message, reload in
                guard !success || reload else { return }
                guard let message = message else { return }
                let title = success ? "Success" : "Error"
                self?.alert(title: title, message: message)
            })
            .disposed(by: disposeBag)
        
        viewModel.dataUpdated
            .drive(onNext: { [weak self] updated in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        
        // Outputs
        reloadDataButton.rx.tap
            .bind(to: viewModel.requestReloadData)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .map { [unowned self] indexPath in
                return self.viewModel.factAtIndexPath(indexPath)
            }
            .bind(to: viewModel.selectFact)
            .disposed(by: disposeBag)
        
        tableView.rx.itemAccessoryButtonTapped
            .map { [unowned self] indexPath in
                return self.viewModel.factAtIndexPath(indexPath)
            }
            .bind(to: viewModel.requestFactDetails)
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refreshGeosAndValues()
    }
}

// MARK: - Extension - UITableViewDelegate
extension LineSpecsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 27
    }
}


