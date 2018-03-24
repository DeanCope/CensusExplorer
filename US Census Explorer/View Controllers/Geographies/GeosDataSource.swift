//
//  GeosDataSource.swift
//  CensusAPI
//
//  Created by Dean Copeland on 1/13/18.
//  Copyright © 2018 Dean Copeland. All rights reserved.
//

import UIKit
import CoreData

class GeosDataSource: NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    private let censusDataSource: CensusDataSource!
    
    private var stack: CoreDataStack? = nil
    private var context: NSManagedObjectContext? = nil
    
    lazy var fetchedResultsController: NSFetchedResultsController<Geography> = {
        let fr: NSFetchRequest<Geography> = Geography.fetchRequest()
        fr.sortDescriptors = [NSSortDescriptor(key: "level", ascending: true), NSSortDescriptor(key: "name", ascending: true)]
        fr.predicate = nil
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: self.context!, sectionNameKeyPath: #keyPath(Geography.level), cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to fetch geos from the local DB")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        return fetchedResultsController
    }()
    
    init(dataSource: CensusDataSource) {
        
        self.censusDataSource = dataSource
        // Save the stack and context for convenience
        stack = censusDataSource.stack
        context = stack!.context
    }
    
    func doFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to fetch geos from the local DB")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections
        guard let sections = fetchedResultsController.sections else {
         //   alert(message: "No sections were found in the data.")
            return 0
        }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
         //   self.alert(message: "Unexpected Section")
            return "Unexpected Section"
        }
        guard let name = CensusClient.GeoLevels[sectionInfo.name] else {
        //    self.alert(message: "Unexpected geo level found: \(sectionInfo.name)")
            return "Unexpected geo level"
        }
        return name
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
        //    self.alert(message: "Unexpected section number found: \(section)")
            fatalError("Unexpected Section number: \(section)")
        }
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StateCell.Identifier, for: indexPath)
        
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
    
    func getGeography(at indexPath: IndexPath) -> Geography {
        return fetchedResultsController.object(at: indexPath)
    }
    
    func selectGeography(geo: Geography, selected: Bool) {
        geo.isSelected = selected
        stack!.save()
    }

}
