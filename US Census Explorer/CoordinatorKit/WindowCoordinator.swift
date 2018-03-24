//
//  WindowCoordinator.swift
//  CoordinatorKit
//
//  Created by Ian MacCallum on 10/11/17.
//
import Foundation

public protocol WindowCoordinatorType: BaseCoordinatorType {
	var router: WindowRouterType { get }
}

open class WindowCoordinator: NSObject, WindowCoordinatorType {
	
	public var childCoordinators: [PresentableCoordinator] = []
	
	open var router: WindowRouterType
	
	public init(router: WindowRouterType) {
		self.router = router
		super.init()
	}
	
	open func start() {  }
	
	public func addChild(_ coordinator: Coordinator) {
		childCoordinators.append(coordinator)
	}
	
	public func removeChild(_ coordinator: Coordinator?) {
		
		if let coordinator = coordinator, let index = childCoordinators.index(of: coordinator) {
			childCoordinators.remove(at: index)
		}
	}
}
