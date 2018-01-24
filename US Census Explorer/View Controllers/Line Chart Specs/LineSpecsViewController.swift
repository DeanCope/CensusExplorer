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

    private var userRequestedReload = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var reloadDataButton: UIButton!
    
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
        
        reloadDataButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.userRequestedReload = true
                self?.viewModel.reloadData()
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .map { [unowned self] indexPath in
                return self.viewModel.factAtIndexPath(indexPath)
            }
            .bind(to: viewModel.selectFact)
            .disposed(by: disposeBag)
        
        tableView.rx.itemAccessoryButtonTapped
            .subscribe(onNext: { [unowned self] indexPath in
                let fact = self.viewModel.factAtIndexPath(indexPath)
                self.alert(title: fact.factName!, message: fact.factDescription)
            })
            .disposed(by: disposeBag)
        
        // Activity Indicator "spinner"
        viewModel.querying
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        // Show/Hide progress Bar and label
        viewModel.querying
            .drive(onNext: { [weak self] querying in
                    self?.progressView.isHidden = !querying
                    self?.progressLabel.isHidden = !querying
                }
            )
            .disposed(by: disposeBag)
        
        viewModel.dataUpdated
            .drive(onNext: { [weak self] updated in
            self?.tableView.reloadData()
        })
        .disposed(by: disposeBag)
        
        // Progress view
        viewModel.queryProgress
            .drive(onNext: { [weak self] progress in
                // Do not animate resetting back to 0 progress
                let animated = progress > 0.0
                self?.progressView.setProgress(progress, animated: animated)
            })
            .disposed(by: disposeBag)
        
        // Progress label
        viewModel.progressMessage
            .drive(progressLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Query completion message
        viewModel.queryCompletion
            .drive (onNext: {[weak self] success, message in
                guard let reload = self?.userRequestedReload else { return }
                guard reload else { return }
                self?.userRequestedReload = false
                var title = "Success"
                if !success {
                    title = "Error"
                }
                if message != nil {
                    self?.alert(title: title, message: message)
                }
            })
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


