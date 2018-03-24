//
//  YearsCoordinator.swift
//  CensusAPI
//
//  Created by Dean Copeland on 1/17/18.
//  Copyright © 2018 Dean Copeland. All rights reserved.
//

import RxSwift

// This is a vertical flow

class YearsCoordinator: Coordinator {
    
    let disposeBag = DisposeBag()
    
    private let store: StoreType
    
    lazy var viewController: YearsTableViewController = {
        let vc = YearsTableViewController.initFromStoryboard()
        return vc
    }()
    
    var onDone: (() -> Void)?
    
    let chartType = ChartType.scatter
    
    init(router: RouterType, store: StoreType) {
        self.store = store
        super.init(router: router)
        let vm = YearsViewModel(chartSpecs: store.getChartSpecs(chartType: .scatter))
        viewController.viewModel = vm
        vm.didChooseYear.subscribe(onNext: { [weak self] year in
            let chartSpecs = self?.store.getChartSpecs(chartType: (self?.chartType)!)
            chartSpecs?.year.value = year
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

