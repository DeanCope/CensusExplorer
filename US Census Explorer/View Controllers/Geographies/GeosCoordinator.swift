//
//  GeosCoordinator.swift
//  CensusAPI
//
//  Created by Dean Copeland on 1/5/18.
//  Copyright © 2018 Dean Copeland. All rights reserved.
//

import RxSwift

// This is a horizontal flow

class GeosCoordinator: Coordinator<DeepLink> {
    
    let disposeBag = DisposeBag()
    
    private let store: StoreType
    
    private var chartType: ChartType!
    
    lazy var viewController: GeosViewController = {
        let vc = GeosViewController.initFromStoryboard()
        return vc
    }()
    
    init(router: RouterType, store: StoreType, chartType: ChartType) {
        self.store = store
        super.init(router: router)
        
        self.chartType = chartType
        
        let vm = GeosViewModel(chartSpecs: store.getChartSpecs(chartType: chartType))
        viewController.viewModel = vm
        vm.didChooseGraphIt.subscribe(onNext: { [weak self] fact in
            self?.graphIt()
        })
        .disposed(by: disposeBag)
    }
    
    // We must override toPresentable() so it doesn't
    // default to the router's navigationController
    override func toPresentable() -> UIViewController {
        return viewController
    }

    private func graphIt() {
        if chartType == .line {
        let coordinator = LineChartCoordinator(router: router, store: store)
            // Maintain a strong reference to avoid deallocation
            addChild(coordinator)
            coordinator.start()
            
            // Avoid retain cycles and don't forget to remove the child when popped
            router.push(coordinator, animated: true) { [weak self, weak coordinator] in
                self?.removeChild(coordinator)
            }
        } else {
        let coordinator = ScatterChartCoordinator(router: router, store: store)
                // Maintain a strong reference to avoid deallocation
                addChild(coordinator)
                coordinator.start()
                
                // Avoid retain cycles and don't forget to remove the child when popped
                router.push(coordinator, animated: true) { [weak self, weak coordinator] in
                    self?.removeChild(coordinator)
                }
            }
    }
}

/*
import UIKit
import RxSwift

/// Type that defines possible coordination results of the `GeosCoordinator`.
///
/// - graphIt: Geos were chosen and graph requested.
/// - cancel: Back button was tapped.

enum GeosCoordinationResult {
  //  case graphIt
    case cancel
}

class GeosCoordinator: BaseCoordinator<GeosCoordinationResult> {
    
    private let navigationController: UINavigationController
    private let chartSpecs: ChartSpecs
    
    let graphIt: AnyObserver<Void>
    
    // MARK: - Outputs
    let didChooseGraphIt: Observable<Void>
    
    init(rootViewController: UINavigationController, chartSpecs: ChartSpecs) {
        self.navigationController = rootViewController
        self.chartSpecs = chartSpecs
        
        let _graphIt = PublishSubject<Void>()
        self.graphIt = _graphIt.asObserver()
        self.didChooseGraphIt = _graphIt.asObservable()
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewController = GeosViewController.initFromStoryboard(name: "Main")
        //let navigationController = UINavigationController(rootViewController: viewController)
        
        let viewModel = GeosViewModel(chartSpecs: chartSpecs)
        viewController.viewModel = viewModel
        
        viewModel.didChooseGraphIt
            .debug("GeosCoordinator GeosViewModel.didChooseGraphIt")
            .bind(to: graphIt)
        .disposed(by: disposeBag)
        
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

