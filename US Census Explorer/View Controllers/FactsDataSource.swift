//
//  FactsDataSource.swift
//  CensusAPI
//
//  Created by Dean Copeland on 10/2/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit
import CoreData

// This class is the table view data source used by both the LineSpecsViewController and the
// ScatterFactsViewController to display the list of Grouped Census Facts to the user.
// This class is used display facts for either the X or Y axis.
// It uses a FetchedResultsController to get the data from Core Data
class FactsDataSource: NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    public var chartSpecs: ChartSpecs?
    public var axis: Axis?
    
    var stack: CoreDataStack? = nil
    var context: NSManagedObjectContext? = nil
    
    lazy var fetchedResultsController: NSFetchedResultsController<CensusFact> = {
        let fr: NSFetchRequest<CensusFact> = CensusFact.fetchRequest()
        fr.sortDescriptors = [NSSortDescriptor(key: "groupName", ascending: true), NSSortDescriptor(key: "factName", ascending: true)]
        fr.predicate = nil
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: self.context!, sectionNameKeyPath: #keyPath(CensusFact.groupName), cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to fetch census facts from the local DB")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        return fetchedResultsController
    }()
    
    override init() {
        
        // Save the stack and context for convenience
        stack = CensusDataSource.sharedInstance.stack
        context = stack!.context
    }
    
    func doFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to fetch census facts from the local DB")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
    }
    
    
    
    public func getFact(at: IndexPath ) -> CensusFact {
        return fetchedResultsController.object(at: at)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return "Unexpected Section"
        }
        return sectionInfo.name
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            fatalError("Unexpected Section number: \(section)")
        }
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FactTableViewCell.Identifier, for: indexPath) as! FactTableViewCell
        
        // Fetch fact
        let fact = fetchedResultsController.object(at: indexPath)
        //print("index: \(indexPath.section) \(indexPath.row) fact: \(fact.factName)")
        // Configure Cell
        cell.factName = fact.factName
        
        guard chartSpecs != nil else {
            return cell
        }
        guard axis != nil else {
            return cell
        }
        
        if let chartSpecsFact = chartSpecs!.getFact(forAxis: axis!) {
            if fact.factName == chartSpecsFact.factName {
                cell.accessoryType = .checkmark
                cell.isSelected = true
            } else {
                cell.accessoryType = .none
            }
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}


