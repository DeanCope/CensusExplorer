//
//  GeosCoordinator.swift
//  CensusAPI
//
//  Created by Dean Copeland on 1/5/18.
//  Copyright © 2018 Dean Copeland. All rights reserved.
//

import RxSwift

class GeosCoordinator: Coordinator {
    
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
        
        let vm = GeosViewModel(dataSource: store.getDataSource(), chartSpecs: store.getChartSpecs(chartType: chartType))
        viewController.viewModel = vm
        
        vm.didChooseGraphIt.subscribe(onNext: { [weak self] in
            if self?.chartType == .line {
                self?.pushChild(coordinator: LineChartCoordinator(router: router, store: store))
            } else {
                self?.pushChild(coordinator: ScatterChartCoordinator(router: router, store: store))
            }
        })
        .disposed(by: disposeBag)
    }
    
    // We must override toPresentable() so it doesn't
    // default to the router's navigationController
    override func toPresentable() -> UIViewController {
        return viewController
    }
}
