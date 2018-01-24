//
//  CensusValue+CoreDataClass.swift
//  CensusAPI
//
//  Created by Dean Copeland on 6/14/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import Foundation
import CoreData


public class CensusValue: NSManagedObject {
    
    
    //MARK: Initializers
    // construct a CensusValue from an Array
    // This is a failable initializer.  If any of the required properties are not found, then no instance is created.
    convenience init?(array: [String?], fact: CensusFact, context: NSManagedObjectContext) {
        
        guard array[0] != nil else {
            return nil
        }
        guard let value = Double(array[0]!) else {
            return nil
        }
        
        let year = array[1]
        let geoName = array[2]
        
        let request: NSFetchRequest<Geography> = Geography.fetchRequest()
        request.predicate = NSPredicate(format: "name=%@", geoName!)
        let geography = (try? context.fetch(request))?.first
        
        if geography == nil {
            return nil
        }
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "CensusValue", in: context) {
            self.init(entity: ent, insertInto: context)
            self.value = value
            self.year = Int16(year!)!
            self.hasDescription = fact
            self.appliesToGeography = geography
        } else {
            fatalError("Unable to find Entity name for CensusValue!")
        }
    }
    
    convenience init?(value: String?, geo: Geography, year: Int, fact: CensusFact, context: NSManagedObjectContext) {
        
        guard value != nil else {
            return nil
        }

        guard let valueDouble = Double(value!) else {
            return nil
        }
        let year = Int16(year)
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "CensusValue", in: context) {
            self.init(entity: ent, insertInto: context)
            self.value = valueDouble
            self.year = Int16(year)
            self.hasDescription = fact
            self.appliesToGeography = geo
        } else {
            fatalError("Unable to find Entity name for CensusValue!")
        }
    }
    
    static func valuesFromResults(_ results: [[String?]], forFact: CensusFact, context: NSManagedObjectContext) -> [CensusValue] {
        
        var values = [CensusValue]()
    
        for result in results {
            if let value = CensusValue(array: result, fact: forFact, context: context) {
                values.append(value)
            }
        }
        
        return values
    }
    
    static func acsValuesFromResults(_ results: [[String?]], forFact: CensusFact, context: NSManagedObjectContext) -> [CensusValue] {
        
        var values = [CensusValue]()
        
        var firstResult = true
        
        // yearMapping tells us what year each item position in the results is for
        var yearMapping = [Int: Int]()
        var nameIndex = 0
        
        for result in results {
            if firstResult {
                // The first result (row) contains metadata that identifies each of the columns.
                // We use this first row to populate the yearMapping dictionary.
                firstResult = false
                var index = 0
                for element in result {
                    if element == "state" || element == "us" {
                        // ignore
                    }
                    else if element == "NAME" {
                        nameIndex = index
                    } else {
                        // Extract the year
                        let start = element?.index((element?.startIndex)!, offsetBy: 5)
                        let end = element?.index((element?.startIndex)!, offsetBy: 9)
                        let range = start!..<end!
                        
                        if let yearString = element?.substring(with: range) {
                            yearMapping[index] = Int(yearString)
                        } else {
                            fatalError("Could not parse year from element: \(element!)")
                        }
                    }
                    index += 1
                }
            } else {
                // Find the geography for this result
                let request: NSFetchRequest<Geography> = Geography.fetchRequest()
                request.predicate = NSPredicate(format: "name=%@", result[nameIndex]!)
                //request.predicate = NSPredicate(format: "fipsCode=%@", result[fipsCodeIndex]!)
                let geography = (try? context.fetch(request))?.first
                
                if let geography = geography {
                    var index = 0
                    for element in result {
                       // if yearMapping[index] != nil { //index > 0 {
                            if let year = yearMapping[index] {
                                if let value = CensusValue(value: element, geo: geography, year: year, fact: forFact, context: context) {
                                    values.append(value)
                                }
                            }
                        //}
                        index += 1
                    }
                }
            }
        }
        
        return values
    }
    
}
