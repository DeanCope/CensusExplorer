//
//  GeosViewController.swift
//  CensusAPI
//
//  Created by Dean Copeland on 6/6/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit
import CoreData

class GeosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, SettableChartSpecs {
    
    private struct Storyboard {
        static let showLineChartSegueId = "ShowLineChart"
        static let showScatterChartSegueId = "ShowScatterChart"
    }

    var stack: CoreDataStack? = nil
    var context: NSManagedObjectContext? = nil
    
    var chartSpecs: ChartSpecs?
    
    // Observe gotCensusValues so we can enable the GraphIt button when the values are available.
    var gotCensusValuesObserver: Any?
    
    lazy var fetchedResultsController: NSFetchedResultsController<Geography> = {
        let fr: NSFetchRequest<Geography> = Geography.fetchRequest()
        fr.sortDescriptors = [NSSortDescriptor(key: "level", ascending: true), NSSortDescriptor(key: "name", ascending: true)]
        fr.predicate = nil
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: self.context!, sectionNameKeyPath: #keyPath(Geography.level), cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var graphItButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Save the stack and context for convenience
        stack = CensusDataSource.sharedInstance.stack
        context = stack!.context
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            self.alert(message: error.localizedDescription)
            print("Unable to fetch geographies from the local DB")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }

        self.title = chartSpecs?.description ?? ""
        self.instructionsLabel.text = "Choose the whole country and/or one or more states."
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Only enable the GraphIt button if we have already received the census values from the server
        if CensusDataSource.sharedInstance.gotCensusValues {
            graphItButton.isEnabled = true
        } else {
            graphItButton.isEnabled = false
            gotCensusValuesObserver = startObserving(notificationName: NotificationNames.GotCensusValues) {notification in
                self.graphItButton.isEnabled = true
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopObservingNotification(observer: gotCensusValuesObserver)
    }
    
    @IBAction func graphIt(_ sender: Any) {
        switch chartSpecs?.chartType {
        case nil: break
        case .line?:
            // Segue to the Line Chart controller
            self.performSegue(withIdentifier: Storyboard.showLineChartSegueId, sender: self)
        case .scatter?:
            // Segue to the Scatter Chart controller
            self.performSegue(withIdentifier: Storyboard.showScatterChartSegueId, sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch chartSpecs?.chartType {
        case nil: break
        case .line?:
            if segue.identifier == Storyboard.showLineChartSegueId {
                let chartViewController = segue.destination as! LineChartViewController
                // Configure the target view controller with the chart specs
                chartViewController.chartSpecs = chartSpecs
            }
        case .scatter?:
            if segue.identifier == Storyboard.showScatterChartSegueId {
                let chartViewController = segue.destination as! ScatterChartViewController
                // Configure the target view controller with the census fact of interest
                chartViewController.chartSpecs = chartSpecs
            }
        }
    }
    
    @IBAction func deselectAllRows(_ sender: Any) {
        CensusDataSource.sharedInstance.selectAllGeographies(false){ (success, error) in
            if success {
                self.tableView.reloadData()
            } else {
                var message = "Error selecting all rows"
                if let error = error {
                    message = message + ": \(error.localizedDescription)"
                }
                self.alert(message: message)
            }
        }
    }
    
    @IBAction func selectAllRows(_ sender: Any) {
        CensusDataSource.sharedInstance.selectAllGeographies(true){ (success, error) in
            if success {
                self.tableView.reloadData()
            } else {
                var message = "Error selecting all rows"
                if let error = error {
                    message = message + ": \(error.localizedDescription)"
                }
                self.alert(message: message)
            }
        }
    }
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections
        guard let sections = fetchedResultsController.sections else {
            alert(message: "No sections were found in the data.")
            return 0
        }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            self.alert(message: "Unexpected Section")
            return "Unexpected Section"
        }
        guard let name = CensusClient.GeoLevels[sectionInfo.name] else {
            self.alert(message: "Unexpected geo level found: \(sectionInfo.name)")
            return "Unexpected geo level"
        }
        return name
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            self.alert(message: "Unexpected section number found: \(section)")
            fatalError("Unexpected Section number: \(section)")
        }
        return sectionInfo.numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StateCell", for: indexPath)
        
        // Fetch State
        let state = fetchedResultsController.object(at: indexPath)
        
        // Configure Cell
        if let stateCell = cell as? StateCell {
            stateCell.state = state
        }
        
        if state.isSelected {
            cell.accessoryType = .checkmark
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.bottom)
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? StateCell {
            cell.accessoryType = .checkmark
            cell.state?.isSelected = true
            stack!.save()
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? StateCell {
            cell.accessoryType = .none
            cell.state?.isSelected = false
            stack!.save()
        }
    }
}
