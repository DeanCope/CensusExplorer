//
//  LineSpecsCoordinator.swift
//  CensusAPI
//
//  Created by Dean Copeland on 12/31/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import RxSwift

class LineSpecsCoordinator: Coordinator<DeepLink> {
    
    let disposeBag = DisposeBag()
    
    private let store: StoreType
    
    lazy var viewController: LineSpecsViewController = {
        let vc = LineSpecsViewController.initFromStoryboard()
        return vc
    }()
    
    init(router: RouterType, store: StoreType) {
        self.store = store
        super.init(router: router)
        let vm = LineSpecsViewModel()
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
        
        let coordinator = GeosCoordinator(router: router, store: store, chartType: .line)
        
        // Maintain a strong reference to avoid deallocation
        addChild(coordinator)
        coordinator.start()
        
        // Avoid retain cycles and don't forget to remove the child when popped
        router.push(coordinator, animated: true) { [weak self, weak coordinator] in
            self?.removeChild(coordinator)
        }
    }
}


/*
import UIKit
import RxSwift

class LineMainCoordinator: BaseCoordinator<Void> {
    
    private let rootViewController: UIViewController
    private var chartSpecs = ChartSpecs(chartType: .line, factX: nil, factY: nil, year: 2016)
    
    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }
    
    var navigationController: UINavigationController!
    
    override func start() -> Observable<Void> {
        
        let vc = LineSpecsViewController.initFromStoryboard()
        vc.viewModel = LineSpecsViewModel()
        vc.tabBarItem = UITabBarItem(title: "Line",
                                     image: UIImage(named: "Chart"),
                                     selectedImage: UIImage(named: "Chart"))
        navigationController = UINavigationController(rootViewController: vc)
        
        // Actions:
        vc.viewModel.didSelectFact
            //.asObservable()
            .debug("didSelectFact in Main coordinator")
            .subscribe({ [weak self] factElement in
                // save fact to chart specs
                if let fact = factElement.element {
                    self?.chartSpecs.setFact(fact, forAxis: Axis.y)
                    self?.showGeos(on: (self?.navigationController)!)
                }
            })
            .disposed(by: disposeBag)
        
        return Observable.never()
        
    }
    private func showGeos(on rootViewController: UINavigationController) -> Observable<Void> {
        let geosCoordinator = GeosCoordinator(rootViewController: rootViewController, chartSpecs: chartSpecs)
        geosCoordinator.didChooseGraphIt
            .subscribe({ [weak self] _ in
                self?.showGraph(on: (self?.navigationController)!)
            })
        return coordinate(to: geosCoordinator)
            .map { result in
                switch result {
           //     case .graphIt: return
                case .cancel: return
                }
        }
    }
    
    private func showGraph(on rootViewController: UINavigationController) -> Observable<Void> {
        let graphCoordinator = LineChartCoordinator(rootViewController: rootViewController, chartSpecs: chartSpecs)

        return coordinate(to: graphCoordinator)
            .map { result in
                switch result {
                //     case .graphIt: return
                case .cancel: return
                }
        }
    }
}
 */
