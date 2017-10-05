//
//  SettingsViewController.swift
//  CensusAPI
//
//  Created by Dean Copeland on 9/23/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    var getGeographiesErrorObserver: Any?
    var getValuesErrorObserver: Any?
    var gotValuesObserver: Any?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getValuesErrorObserver = startObservingGetCensusValuesErrorNotification()
        gotValuesObserver = startObservingGotCensusValuesNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopObservingNotification(observer: getGeographiesErrorObserver)
        stopObservingNotification(observer: getValuesErrorObserver)
        stopObservingNotification(observer: gotValuesObserver)
    }

}
