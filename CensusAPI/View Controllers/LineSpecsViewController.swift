//
//  LineSpecsViewController.swift
//  CensusAPI
//
//  Created by Dean Copeland on 8/29/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit

class LineSpecsViewController: UIViewController {
    
    fileprivate struct Storyboard {
        static let chooseGeoSegueId = "ChooseGeos"
    }
    
    fileprivate var factsDataSource = FactsDataSource()
    
    // NotificationCenter is being used in case the user switches to another view while a long-running network request is in progress.  This allows us to have the report of success or error to appear on other windows (accessed from the tab bar).
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = factsDataSource
        
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "HeaderTableViewCell") as! HeaderTableViewCell
        headerCell.sectionName = "Touch a topic to explore."
        tableView.tableHeaderView = headerCell
    }
    
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
        
        //facts = CensusDataSource.sharedInstance.getAllFacts()
        activityIndicator.startAnimating()
        
        CensusDataSource.sharedInstance.retrieveGeographies() {
            (success, error) in
            if success {
                CensusDataSource.sharedInstance.retrieveAllCensusValues() { (success, error) in
                    if success {
                        //self.facts = CensusDataSource.sharedInstance.getAllFacts()
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
                if let error = userInfo[NotificationNames.CensusError] as? CensusError {
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
        }
        return observer
    }

    
    @IBAction func reloadDataRequested(_ sender: Any) {
        userRequestedReload = true
        reloadDataButton.isEnabled = false
        activityIndicator.startAnimating()
        printDBStats()
        CensusDataSource.sharedInstance.deleteAllGeographies()
        printDBStats()
        CensusDataSource.sharedInstance.deleteAllCensusFacts()
        refreshGeosAndValues()
    }
    
    func printDBStats() {
        print("There are \(CensusDataSource.sharedInstance.getAllCensusValues()!.count) census values")
        }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Figure out which row was selected
        if let indexPath = tableView.indexPathForSelectedRow {
            if segue.identifier == Storyboard.chooseGeoSegueId {
                let destViewController = segue.destination as! SettableChartSpecs
                let fact = factsDataSource.getFact(at: indexPath)
                // Configure the target view controller with the chart specs
                let specs = ChartSpecs(chartType: .line, factX: nil, factY: fact, year: nil)
                destViewController.chartSpecs = specs
            }
        }
    }
}

// MARK: - Extension - UITableViewDelegate

extension LineSpecsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Storyboard.chooseGeoSegueId, sender: self)
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let fact = factsDataSource.getFact(at: indexPath)
        alert(title: fact.factName!, message: fact.factDescription)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 27
    }
 
}


