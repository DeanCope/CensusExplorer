//
//  AppCoordinator.swift
//  CensusAPI
//
//
import Foundation
import UIKit
import RxSwift
import RxCocoa

class AppCoordinator: Coordinator, UITabBarControllerDelegate {
    
    //var description: String
    
    let disposeBag = DisposeBag()
    
    let tabBarController = UITabBarController()
    
    var tabs: [UIViewController: Coordinator] = [:]
    
    lazy var lineCoordinator: LineSpecsCoordinator = {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(title: "Line",
                                                       image: UIImage(named: "Chart"),
                                                       selectedImage: UIImage(named: "Chart"))
        navigationController.tabBarItem.tag = 0
        let router = Router(navigationController: navigationController)
        let coordinator = LineSpecsCoordinator(router: router, store: store)
        return coordinator
    }()
  
    lazy var scatterCoordinator: ScatterSpecsCoordinator = {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(title: "Scatter",
                                                       image: UIImage(named: "icons8-Scatter Plot-30"),
                                                       selectedImage: UIImage(named: "icons8-Scatter Plot-30"))
        navigationController.tabBarItem.tag = 1
        let router = Router(navigationController: navigationController)
        let coordinator = ScatterSpecsCoordinator(router: router, store: store)
        return coordinator
    }()
    
    lazy var settingsCoordinator: SettingsCoordinator = {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(title: "Settings",
                                                       image: UIImage(named: "icons8-Settings-30"),
                                                       selectedImage: UIImage(named: "icons8-Settings Filled-30"))
        navigationController.tabBarItem.tag = 2
        let router = Router(navigationController: navigationController)
        let coordinator = SettingsCoordinator(router: router, store: store)
        return coordinator
    }()
    
    lazy var helpCoordinator: HelpCoordinator = {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(title: "Help",
                                                       image: UIImage(named: "icons8-Help-30"),
                                                       selectedImage: UIImage(named: "icons8-Help Filled-30"))
        navigationController.tabBarItem.tag = 3
        let router = Router(navigationController: navigationController)
        let coordinator = HelpCoordinator(router: router, store: store)
        return coordinator
    }()

    private let store: StoreType
    private var preventNavigation = Variable<Bool>(false)
    
    init(router: RouterType, store: StoreType) {
        self.store = store
        super.init(router: router)
        router.setRootModule(tabBarController, hideBar: true)
        tabBarController.delegate = self
        setTabs([lineCoordinator, scatterCoordinator, settingsCoordinator, helpCoordinator])
        
        store.getDataSource().querying.drive(preventNavigation)
        .disposed(by: disposeBag)
        
    }
    
    func setTabs(_ coordinators: [Coordinator], animated: Bool = false) {
        
        tabs = [:]
        
        // Store view controller to coordinator mapping
        let vcs = coordinators.map { coordinator -> UIViewController in
            let viewController = coordinator.toPresentable()
            tabs[viewController] = coordinator
            return viewController
        }
        
        tabBarController.setViewControllers(vcs, animated: animated)
    }
    
    // MARK: UITabBarControllerDelegate
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if preventNavigation.value {
            return false
        } else {
            return true
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
}

