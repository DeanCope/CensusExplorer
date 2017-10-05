//
//  CensusFact+CoreDataClass.swift
//  CensusAPI
//
//  Created by Dean Copeland on 6/14/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import Foundation
import CoreData


public class CensusFact: NSManagedObject {
    //MARK: Initializers
    // construct a Fact
    // This is a failable initializer.  If any of the required properties are not found, then no instance is created.
    
  //  factDescription: String?
  //  factName: String?
  //  variableName: String?
    
    convenience init?(sourceId: String, variableName: String, group: String, name: String, description: String, unit: String, context: NSManagedObjectContext) {
        
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "CensusFact", in: context) {
                self.init(entity: ent, insertInto: context)
                self.sourceId = sourceId
                self.factDescription = description
                self.groupName = group
                self.factName = name
                self.unit = unit
                self.variableName = variableName
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
    
    func hasData() -> Bool {
        if describes?.count == 0 {
            return false
        } else {
            return true
        }
    }
}
