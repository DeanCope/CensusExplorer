//
//  ScatterChartCoordinator.swift
//  CensusAPI
//
//  Created by Dean Copeland on 1/24/18.
//  Copyright © 2018 Dean Copeland. All rights reserved.
//

import Foundation

import UIKit
import RxSwift

// This is a horizontal flow

class ScatterChartCoordinator: Coordinator {
    
    let disposeBag = DisposeBag()
    
    private let store: StoreType
    
    lazy var viewController: ScatterChartViewController = {
        let vc = ScatterChartViewController.initFromStoryboard()
        return vc
    }()
    
    init(router: RouterType, store: StoreType) {
        self.store = store
        super.init(router: router)
        let vm = ScatterChartViewModel(dataSource: store.getDataSource(), chartSpecs: store.getChartSpecs(chartType: .scatter))
        viewController.viewModel = vm
        
        /*
        vm.didChooseSave.subscribe(onNext: { [weak self] fact in
            self?.save()
        })
            .disposed(by: disposeBag)
 */
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
