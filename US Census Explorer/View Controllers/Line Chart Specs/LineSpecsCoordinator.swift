//
//  LineSpecsCoordinator.swift
//  CensusAPI
//
//  Created by Dean Copeland on 12/31/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import RxSwift

class LineSpecsCoordinator: Coordinator {
    
    let disposeBag = DisposeBag()
    
    private let store: StoreType
    
    lazy var viewController: LineSpecsViewController = {
        let vc = LineSpecsViewController.initFromStoryboard()
        return vc
    }()
    
    init(router: RouterType, store: StoreType) {
        self.store = store
        super.init(router: router)
        let vm = LineSpecsViewModel(dataSource: store.getDataSource())
        viewController.viewModel = vm
        
        vm.didSelectFact
            .subscribe(onNext: { [weak self] fact in
                self?.didSelectFact(fact)
            })
            .disposed(by: disposeBag)
        
        router.setRootModule(viewController, hideBar: false)
    }
    
    private func didSelectFact(_ fact: CensusFact) {
        
        store.setChartSpecs(chartType: .line, chartSpecs: ChartSpecs(chartType: .line, factX: nil, factY: fact))
        
        pushChild(coordinator: GeosCoordinator(router: router, store: store, chartType: .line))
 
    }
}

