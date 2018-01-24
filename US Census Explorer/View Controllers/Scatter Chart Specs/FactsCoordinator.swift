//
//  FactsCoordinator.swift
//  CensusAPI
//
//  Created by Dean Copeland on 1/15/18.
//  Copyright © 2018 Dean Copeland. All rights reserved.
//

import RxSwift

// This is a vertical flow

class FactsCoordinator: Coordinator<DeepLink> {
    
    let disposeBag = DisposeBag()
    
    private let store: StoreType
    
    lazy var viewController: FactsViewController = {
        let vc = FactsViewController.initFromStoryboard()
        return vc
    }()
    
    var onDone: (() -> Void)?
    
    init(router: RouterType, store: StoreType, axis: Axis) {
        self.store = store
        super.init(router: router)
        let vm = FactsViewModel(axis: axis)
        viewController.viewModel = vm
        vm.didChooseFact.subscribe(onNext: { [weak self] fact in
            var chartSpecs = self?.store.getChartSpecs(chartType: .scatter)
            chartSpecs?.setFact(fact, forAxis: axis)
            self?.onDone?()
        })
        .disposed(by: disposeBag)
    }
    
    // We must override toPresentable() so it doesn't
    // default to the router's navigationController
    override func toPresentable() -> UIViewController {
        return viewController
    }
}
