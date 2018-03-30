//
//  LineChartCoordinator.swift
//  CensusAPI
//
//  Created by Dean Copeland on 1/10/18.
//  Copyright © 2018 Dean Copeland. All rights reserved.
//

import UIKit
import RxSwift

// This is a horizontal flow

class LineChartCoordinator: Coordinator {
    
    let disposeBag = DisposeBag()
    
    private let store: StoreType
    
    lazy var viewController: LineChartViewController = {
        let vc = LineChartViewController.initFromStoryboard()
        return vc
    }()

    init(router: RouterType, store: StoreType) {
        self.store = store
        super.init(router: router)
        let vm = LineChartViewModel(dataSource: store.getDataSource(), chartSpecs: store.getChartSpecs(chartType: .line))
        viewController.viewModel = vm
        
        vm.didChooseSave.subscribe(onNext: { [weak self] fact in
            self?.save()
        })
        .disposed(by: disposeBag)
        
        let settingsVC =  SettingsViewController.initFromStoryboard()
        settingsVC.viewModel = SettingsViewModel()
        viewController.settingsViewController = settingsVC
    }
    
    // We must override toPresentable() so it doesn't
    // default to the router's navigationController
    override func toPresentable() -> UIViewController {
        return viewController
    }

    private func save() {
        //TODO:
        /*
        let coordinator = LineChartCoordinator(router: router, store: store)
        
        // Maintain a strong reference to avoid deallocation
        addChild(coordinator)
        coordinator.start()
        
        // Avoid retain cycles and don't forget to remove the child when popped
        router.push(coordinator, animated: true) { [weak self, weak coordinator] in
            self?.removeChild(coordinator)
        }
 */
    }
}

