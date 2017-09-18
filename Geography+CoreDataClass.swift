//
//  Geography+CoreDataClass.swift
//  CensusAPI
//
//  Created by Dean Copeland on 6/14/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import Foundation
import CoreData


public class Geography: NSManagedObject {

    //MARK: Initializers
    // construct a Grography from an Array
    // This is a failable initializer.  If any of the required properties are not found, then no instance is created.
    convenience init?(array: [String], context: NSManagedObjectContext) {
        
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "Geography", in: context) {
            
            let arraySize = array.count
            
            guard arraySize == 4 else {
                return nil
            }
            guard array[0] != "NAME" else {
                return nil
            }
            
            self.init(entity: ent, insertInto: context)
            self.name = array[0]
            self.level = array[1]
            self.fipsCode = array[3]
            if self.name == "United States" {
                self.isSelected = true
            } else {
                self.isSelected = false
            }
            
        } else {
            fatalError("Unable to find Entity name for Geography!")
        }
        
    }
    
    static func valuesFromResults(_ results: [[String]], context: NSManagedObjectContext) -> [Geography] {
        
        var geographies = [Geography]()
        
        for result in results {
            if let value = Geography(array: result, context: context) {
                geographies.append(value)
            }
        }
        
        return geographies
    }

    
    
}
