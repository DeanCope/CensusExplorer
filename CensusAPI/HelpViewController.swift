//
//  HelpViewController.swift
//  CensusAPI
//
//  Created by Dean Copeland on 9/18/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    
    
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
    
    @IBAction func linkToCensusBureau(_ sender: Any) {
        if let url = URL(string: "https://www.census.gov/"){
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @IBAction func linkToIcons8(_ sender: Any) {
        if let url = URL(string: "https://icons8.com/"){
           UIApplication.shared.open(url, options: [:])
        }
    }
    
    @IBAction func linkToChartsFramework(_ sender: Any) {
        if let url = URL(string: "https://github.com/danielgindi/Charts"){
            UIApplication.shared.open(url, options: [:])
        }
    }

}
