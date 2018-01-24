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

class LineChartCoordinator: Coordinator<DeepLink> {
    
    let disposeBag = DisposeBag()
    
    private let store: StoreType
    
    lazy var viewController: LineChartViewController = {
        let vc = LineChartViewController.initFromStoryboard()
        return vc
    }()

    init(router: RouterType, store: StoreType) {
        self.store = store
        super.init(router: router)
        let vm = LineChartViewModel(chartSpecs: store.getChartSpecs(chartType: .line))
        viewController.viewModel = vm
        vm.didChooseSave.subscribe(onNext: { [weak self] fact in
            self?.save()
        })
        .disposed(by: disposeBag)
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


/*
import UIKit
import RxSwift

/// Type that defines possible coordination results of the `LineChartCoordinator`.
///
///
/// - cancel: Back button was tapped.
enum LineChartCoordinationResult {
    
    case cancel
}

class LineChartCoordinator: BaseCoordinator<LineChartCoordinationResult> {
    
    private let navigationController: UINavigationController
    private let chartSpecs: ChartSpecs
    
    init(rootViewController: UINavigationController, chartSpecs: ChartSpecs) {
        self.navigationController = rootViewController
        self.chartSpecs = chartSpecs
    }
    
    override func start() -> Observable<LineChartCoordinationResult> {
        let viewController = LineChartViewController.initFromStoryboard(name: "Main")
        
        let viewModel = LineChartViewModel(chartSpecs: chartSpecs)
        viewController.viewModel = viewModel
        
        viewModel.didCancel
            .debug("GeosViewModel.didCancel")
            .take(1)
            .subscribe(onNext: { [weak self] event in
                self?.navigationController.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        let cancel = viewModel.didCancel.map {
            _ in CoordinationResult.cancel
            
            }
            .debug("geos coordinator didCancel")
        
        navigationController.pushViewController(viewController, animated: true)
        
        
        return cancel
            //Observable
            //.merge(cancel, graphIt)
            .take(1)
            .do(onNext: { [weak self] _ in
                //self?.rootViewController.dismiss(animated: true)
                self?.navigationController.popViewController(animated: true)
            })
    }
}
 */
