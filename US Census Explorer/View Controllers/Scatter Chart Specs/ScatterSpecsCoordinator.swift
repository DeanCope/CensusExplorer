//
//  ScatterSpecsCoordinator.swift
//  CensusAPI
//
//  Created by Dean Copeland on 1/13/18.
//  Copyright © 2018 Dean Copeland. All rights reserved.
//

import RxSwift

class ScatterSpecsCoordinator: Coordinator<DeepLink> {
    
    let disposeBag = DisposeBag()
    
    private let store: StoreType
    
    enum ScatterSpecItem {
        case topicX
        case topicY
        case year
    }
    
    lazy var viewController: ScatterSpecsTableViewController = {
        let vc = ScatterSpecsTableViewController.initFromStoryboard()
        return vc
    }()
    
    init(router: RouterType, store: StoreType) {
        self.store = store
        super.init(router: router)
        let vm = ScatterSpecsViewModel(store: store)
        viewController.viewModel = vm
        
        vm.didSelectItem
            .subscribe(onNext: { [weak self] item in
                self?.didSelectItem(item)
            })
            .disposed(by: disposeBag)
        
        vm.didChooseContinue
            .subscribe(onNext: { [weak self] in
                self?.didChooseContinue()
            })
            .disposed(by: disposeBag)
 
        router.setRootModule(viewController, hideBar: false)
    }
    
    private func didChooseContinue() {
        let coordinator = GeosCoordinator(router: router, store: store, chartType: .scatter)

        // Maintain a strong reference to avoid deallocation
        addChild(coordinator)
        coordinator.start()
        
        // Avoid retain cycles and don't forget to remove the child when popped
        router.push(coordinator, animated: true) { [weak self, weak coordinator] in
            self?.removeChild(coordinator)
        }
        
    }
    
    private func didSelectItem(_ item: ScatterSpecItem) {
        switch item {
        case .topicX:
            let coordinator = FactsCoordinator(router: router, store: store, axis: Axis.x)
            coordinator.onDone = { [weak self] in
                self?.router.popModule(animated: true)
            }
            // Maintain a strong reference to avoid deallocation
            addChild(coordinator)
            coordinator.start()
            router.push(coordinator, animated: true) { [weak self, weak coordinator] in
                self?.removeChild(coordinator)
            }
        case .topicY:
            let coordinator = FactsCoordinator(router: router, store: store, axis: Axis.y)
            coordinator.onDone = { [weak self] in
                self?.router.popModule(animated: true)
            }
            // Maintain a strong reference to avoid deallocation
            addChild(coordinator)
            coordinator.start()
            router.push(coordinator, animated: true) { [weak self, weak coordinator] in
                self?.removeChild(coordinator)
            }
        case .year:
            let coordinator = YearsCoordinator(router: router, store: store)
            coordinator.onDone = { [weak self] in
                self?.router.popModule(animated: true)
            }
            // Maintain a strong reference to avoid deallocation
            addChild(coordinator)
            coordinator.start()
            // Avoid retain cycles and don't forget to remove the child when dismissed
            router.push(coordinator, animated: true) { [weak self, weak coordinator] in
                self?.removeChild(coordinator)
            }
        }
    }
}
