//
//  HelpCoordinator.swift
//  CensusAPI
//
//  Created by Dean Copeland on 1/14/18.
//  Copyright © 2018 Dean Copeland. All rights reserved.
//

import RxSwift

class HelpCoordinator: Coordinator {
    
    let disposeBag = DisposeBag()
    
    private let store: StoreType
    
    lazy var viewController: HelpViewController = {
        let vc = HelpViewController.initFromStoryboard()
        return vc
    }()
    
    init(router: RouterType, store: StoreType) {
        self.store = store
        super.init(router: router)
        //let vm = SettingsViewModel()
        //viewController.viewModel = vm
        router.setRootModule(viewController, hideBar: false)
    }
}

