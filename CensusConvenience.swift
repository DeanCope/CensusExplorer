//
//  CensusConvenience.swift
//  CensusAPI
//
//  Created by Dean Copeland on 6/14/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import Foundation
import CoreData

extension CensusClient {
    
    // MARK: GET Convenience Methods
    
    // Get ACS values for a single Fact
    func getACSValues(fact: CensusFact, geography: String, context: NSManagedObjectContext, completionHandlerForGet: @escaping (_ result: [CensusValue]?, _ error: CensusClientError?) -> Void) {
        
        /* 1. Specify parameters */
        
        var parameters = [String:AnyObject]()
        parameters[ParameterKeys.Get] = "NAME,\(fact.variableName!)" as AnyObject
        parameters[ParameterKeys.For] = geography as AnyObject
        
        /* 2. Make the request */
        let _ = taskForGETMethod(methods[fact.sourceId!]!, parameters: parameters) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            guard (error == nil) else {
                completionHandlerForGet(nil, error)
                return
            }
            
            // Get the CensusValues
            context.performAndWait {
                let values = CensusValue.acsValuesFromResults(results! as! [[String?]], forFact: fact, context: context)
                completionHandlerForGet(values, nil)
            }
        }
    }

    // Get values from the SAIPE data set
    func getSAIPEValues(fact: CensusFact, geography: String, time: String, context: NSManagedObjectContext, completionHandlerForGet: @escaping (_ result: [CensusValue]?, _ error: CensusClientError?) -> Void) {
        
        /* 1. Specify parameters */
        
        var parameters = [String:AnyObject]()
        parameters[ParameterKeys.Get] = "\(fact.variableName!),YEAR,NAME" as AnyObject
        parameters[ParameterKeys.For] = geography as AnyObject
        parameters[ParameterKeys.Time] = time as AnyObject
        
        /* 2. Make the request */
        let _ = taskForGETMethod(methods[fact.sourceId!]!, parameters: parameters) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            guard (error == nil) else {
                completionHandlerForGet(nil, error)
                return
            }
            
            context.performAndWait {
                let values = CensusValue.valuesFromResults(results! as! [[String]], forFact: fact, context: context)
                completionHandlerForGet(values, nil)
            }
        }
    }
    
    func getGeography(geography: String, time: String, context: NSManagedObjectContext, completionHandlerForGeo: @escaping (_ result: [Geography]?, _ error: CensusClientError?) -> Void) {
        
        /* 1. Specify parameters */
        
        var parameters = [String:AnyObject]()
        
        parameters[ParameterKeys.Get] = "NAME,SUMLEV" as AnyObject
        parameters[ParameterKeys.For] = geography as AnyObject
        parameters[ParameterKeys.Time] = time as AnyObject
        
        /* 2. Make the request */
        let _ = taskForGETMethod(methods[Sources.SAIPE]!, parameters: parameters) { (results, error) in

            /* 3. Send the desired value(s) to completion handler */
            guard (error == nil) else {
                completionHandlerForGeo(nil, error)
                return
            }
            
            // Get the Geography for States
            context.perform {
                let values = Geography.valuesFromResults(results! as! [[String]], context: context)
                completionHandlerForGeo(values, nil)
            }
        }
    }
}
