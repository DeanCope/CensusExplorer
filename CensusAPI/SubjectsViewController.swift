//
//  SubjectsViewController.swift
//  CensusAPI
//
//  Created by Dean Copeland on 8/29/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit

class SubjectsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private struct Storyboard {
        static let cellReuseIdentifier = "SubjectTableViewCell"
        static let chooseGeoSegueId = "ChooseGeos"
    }
    
    var facts = [CensusFact]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    // NotificationCenter is being used in case the user switches to another view while a long-running network request is in progress.  This allows us to have the report of success or error to appear on other windows accessed from the tab bar.
    var getGeographiesErrorObserver: Any?
    var gotGeographiesObserver: Any?
    
    var getValuesProgressObserver: Any?
    var getValuesErrorObserver: Any?
    var gotValuesObserver: Any?
    
    var userRequestedReload = false
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var progressLabel: UILabel!
    
    @IBOutlet weak var reloadDataButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Each of the folowing observers must also be removed ("stopObserving...") in viewWillDisappear
        getGeographiesErrorObserver = startObservingGetGeographiesErrorNotification()
        
        gotGeographiesObserver = startObserving(notificationName: NotificationNames.GotGeographies) {_ in
            self.progressLabel.isHidden = false
            self.progressLabel.text = "Got geographies"
        }
        
        getValuesProgressObserver = startObserving(notificationName: NotificationNames.GetCensusValuesProgress) {notification in
            if let userInfo = notification.userInfo {
                if let message = userInfo[NotificationNames.GetCensusValuesProgressMessage] as? String {
                    self.progressLabel.isHidden = false
                    self.progressLabel.text = message
                }
            }
        }
        
        getValuesErrorObserver = startObservingGetCensusValuesErrorNotification()
        
        gotValuesObserver = startObservingGotCensusValuesNotification()
        
       refreshGeosAndValues()
        
       facts = CensusDataSource.sharedInstance.getAllFacts()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopObservingNotification(observer: getGeographiesErrorObserver)
        stopObservingNotification(observer: gotGeographiesObserver)
        
        stopObservingNotification(observer: getValuesProgressObserver)
        stopObservingNotification(observer: getValuesErrorObserver)
        stopObservingNotification(observer: gotValuesObserver)
    }
    
    private func refreshGeosAndValues() {
        
        facts = [CensusFact]()
        activityIndicator.startAnimating()
        
        CensusDataSource.sharedInstance.retrieveGeographies() {
            (success, error) in
            if success {
                CensusDataSource.sharedInstance.retrieveAllFactValues() { (success, error) in
                    if success {
                        
                    } else {
                        // display notification
                        var message = "Error retrieving data for all facts"
                        if let error = error {
                            message = message + ": \(error.localizedDescription)"
                        }
                        self.alert(message: message)
                    }
                }
            }
        }
    }
    
    func startObservingGetGeographiesErrorNotification() -> Any? {
        
        let observer = startObserving(notificationName: NotificationNames.GetGeographiesError) { notification in
            self.activityIndicator.stopAnimating()
            self.progressLabel.isHidden = true
            var message = "Error getting geographies data"
            if let userInfo = notification.userInfo {
                if let error = userInfo[NotificationNames.CensusClientError] as? CensusClient.CensusClientError {
                    message = "\(message): \(error.localizedDescription)"
                }
            }
            self.alert(message: message)
        }
        return observer
    }

    override func startObservingGotCensusValuesNotification() -> Any? {
        
        let observer = startObserving(notificationName: NotificationNames.GotCensusValues) { notification in
            self.progressLabel.isHidden = true
            self.reloadDataButton.isEnabled = true
            self.activityIndicator.stopAnimating()
            if self.userRequestedReload {
                self.alert(title: "Done", message: "Census data has been reloaded.")
                self.userRequestedReload = false
            }
            self.facts = CensusDataSource.sharedInstance.getAllFacts()
        }
        return observer
    }

    
    @IBAction func reloadDataRequested(_ sender: Any) {
        userRequestedReload = true
        reloadDataButton.isEnabled = false
        activityIndicator.startAnimating()
        CensusDataSource.sharedInstance.deleteAllGeographies()
        CensusDataSource.sharedInstance.deleteAllCensusValues()
        refreshGeosAndValues()
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Touch a topic to explore"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows
        return facts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        /* Get cell type */
        let fact = facts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.cellReuseIdentifier) as UITableViewCell!
        cell?.textLabel!.text = fact.factName

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Storyboard.chooseGeoSegueId, sender: self)
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let fact = facts[indexPath.row]
        alert(title: fact.factName!, message: fact.factDescription)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Figure out which row was selected
        if let row = tableView.indexPathForSelectedRow?.row {
            let fact = facts[row]
            
            if segue.identifier == Storyboard.chooseGeoSegueId {
                let destViewController = segue.destination as! GeosViewController
                destViewController.fact = fact
            }
        }
    }
}
