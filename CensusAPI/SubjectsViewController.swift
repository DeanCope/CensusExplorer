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
    
    var facts = [CensusFact]()
    
    var observer: Any?

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        facts = CensusDataSource.sharedInstance().getAllFacts()
        
        CensusDataSource.sharedInstance().retrieveGeographies() {
            (success, error) in
            if success {
                CensusDataSource.sharedInstance().retrieveAllFactValues() { (success, error) in
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
            } else {
                // display notification
                var message = "Error retrieving geography data"
                if let error = error {
                    message = message + ": \(error.localizedDescription)"
                }
                self.alert(message: message)
            }
        }
        
        
        
        if CensusDataSource.sharedInstance().gotGeographies {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
            let center = NotificationCenter.default
            observer = center.addObserver(forName: NSNotification.Name(rawValue: NotificationNames.GotGeographies), object: nil, queue: OperationQueue.main) {
                notification in
                self.activityIndicator.stopAnimating()
            }
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let observer = observer {
            let center = NotificationCenter.default
            center.removeObserver(observer)
        }
    }


    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections
        return 1
    }
    
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
        
            self.performSegue(withIdentifier: Storyboard.chooseGeoSegueId, sender: self)
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
                // Figure out which row was selected
                let destViewController = segue.destination as! GeosViewController
                destViewController.fact = fact
            }
        }
    }
}
