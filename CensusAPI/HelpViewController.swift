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
        linkToURL("https://www.census.gov/")
    }
    
    @IBAction func linkToIcons8(_ sender: Any) {
        linkToURL("https://icons8.com/")
    }
    
    @IBAction func linkToChartsFramework(_ sender: Any) {
        linkToURL("https://github.com/danielgindi/Charts")
    }
    
    private func linkToURL(_ url: String) {
        if let url = URL(string: url){
            UIApplication.shared.open(url, options: [:])
        }
    }

}
