//
//  AppCoordinator.swift
//  CensusAPI
//
//
import Foundation
import UIKit


class AppCoordinator: Coordinator<DeepLink>, UITabBarControllerDelegate {
    
    let tabBarController = UITabBarController()
    
    var tabs: [UIViewController: Coordinator<DeepLink>] = [:]
    
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
    
    init(router: RouterType, store: StoreType) {
        self.store = store
        super.init(router: router)
        router.setRootModule(tabBarController, hideBar: true)
        tabBarController.delegate = self
        setTabs([lineCoordinator, scatterCoordinator, settingsCoordinator, helpCoordinator])
    }
    
    override func start(with link: DeepLink?) {
        guard let link = link else {
            return
        }
        
        // Forward link or intercept it
        switch link {
        case .line:
            break //presentAuthFlow()
        case .scatter:
            break
            // Switch to the home tab because our link says so
            //guard let index = tabBarController.viewControllers?.index(of: homeCoordinator.toPresentable()) else {
            //    return
           // }
          //  tabBarController.selectedIndex = index
        case .settings:
            break
            
        case .help:
            break
        }
    }
    
    func setTabs(_ coordinators: [Coordinator<DeepLink>], animated: Bool = false) {
        
        tabs = [:]
        
        // Store view controller to coordinator mapping
        let vcs = coordinators.map { coordinator -> UIViewController in
            let viewController = coordinator.toPresentable()
            tabs[viewController] = coordinator
            return viewController
        }
        
        tabBarController.setViewControllers(vcs, animated: animated)
    }
    
    
    // Present a vertical flow
    func presentAuthFlow() {
        /*
        let navigationController = UINavigationController()
        let navRouter = Router(navigationController: navigationController)
        let coordinator = AuthCoordinator(router: navRouter)
        
        coordinator.onCancel = { [weak self, weak coordinator] in
            self?.router.dismissModule(animated: true, completion: nil)
            self?.removeChild(coordinator)
        }
        
        coordinator.onAuthenticated = { [weak self, weak coordinator] token in
            self?.store.token = token
            self?.router.dismissModule(animated: true, completion: nil)
            self?.removeChild(coordinator)
        }
        
        addChild(coordinator)
        coordinator.start()
        router.present(coordinator, animated: true)
 */
    }
    
    
    // MARK: UITabBarControllerDelegate
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        //guard let coordinator = tabs[viewController] else { return true }
        
        // Let's protect this tab because we can
       // if coordinator is AccountCoordinator && !store.isLoggedIn {
       //     presentAuthFlow()
       //     return false
       // } else {
            return true
        //}
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        
    }
}

