//
//  SettingsViewController.swift
//  CensusAPI
//
//  Created by Dean Copeland on 9/23/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit
import RxSwift

protocol SettingsViewControllerDelegate {
    func controllerDidChangeLineChartMode(controller: SettingsViewController)
}

class SettingsViewController: UIViewController, StoryboardInitializable {
    
    let disposeBag = DisposeBag()

    @IBOutlet weak var closeButton: UIButton!
    var getGeographiesErrorObserver: Any?
    var getValuesErrorObserver: Any?
    var gotValuesObserver: Any?
    var settingsTableViewController: SettingsTableViewController?
    var viewModel: SettingsViewModel!
    
    // MARK: -
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Obtain a pointer to the embedded TableViewController so that the ViewModel can be
        // passed to it (in viewDidLoad)
        if segue.identifier == "EmbedSettingsTableViewController" {
            settingsTableViewController = segue.destination as? SettingsTableViewController
        }
    }
    
    override func viewDidLoad() {
        if let settingsTableViewController = settingsTableViewController {
            settingsTableViewController.viewModel = viewModel
        }
        bindViewModel()
    }
    
    private func bindViewModel() {
        closeButton.rx.tap
            .bind(to: viewModel.requestCloseObserver)
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}
