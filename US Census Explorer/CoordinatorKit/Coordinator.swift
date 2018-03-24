import UIKit

public protocol BaseCoordinatorType: class {
	func start()
}

public protocol PresentableCoordinatorType: BaseCoordinatorType, Presentable {}

open class PresentableCoordinator: NSObject, PresentableCoordinatorType {
	
	public override init() {
		super.init()
	}
	
	open func start() {
        
    }

	open func toPresentable() -> UIViewController {
		fatalError("Must override toPresentable()")
	}
}

public protocol CoordinatorType: PresentableCoordinatorType {
	var router: RouterType { get }
}

open class Coordinator: PresentableCoordinator, CoordinatorType  {
	
	public var childCoordinators: [Coordinator] = []
	
	open var router: RouterType
	
	public init(router: RouterType) {
		self.router = router
		super.init()
	}
	
	public func addChild(_ coordinator: Coordinator) {
		childCoordinators.append(coordinator)
	}
	
	public func removeChild(_ coordinator: Coordinator?) {
		
		if let coordinator = coordinator, let index = childCoordinators.index(of: coordinator) {
			childCoordinators.remove(at: index)
		}
	}
    
    open override func toPresentable() -> UIViewController {
        return router.toPresentable()
    }
    
    func pushChild(coordinator: Coordinator) {
        addChild(coordinator)
        coordinator.start()
        
        // Avoid retain cycles and don't forget to remove the child when popped
        router.push(coordinator, animated: true) { [weak self, weak coordinator] in
            self?.removeChild(coordinator)
        }
    }
}
