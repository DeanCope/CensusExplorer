//
//  CensusDataSource.swift
//  CensusAPI
//
//  Created by Dean Copeland on 6/16/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import Foundation
import CoreData
import Charts

class CensusDataSource: NSObject {
    
    var facts = [CensusFact]()
    
    let stack = CoreDataStack(modelName: "Model")!
    
    var context: NSManagedObjectContext? = nil
    
    var gotGeographies = false
    var gotCensusValues = false
    
    // MARK: Initializers
    
    override init() {
        super.init()
        context = stack.context
        
        initializeFacts()
        
        facts = getAllFacts()
    }

    
    func initializeFacts() {
       // deleteAllFacts()
       // deleteAllGeographies()
        let allFacts = getAllFacts()
        
        guard allFacts.count == 0 else {
            return
        }
        
        let facts: [(source: String, prefix: String, suffix: String, name: String, description: String, unit: String)] = [
            (source: CensusClient.Sources.ACS, prefix: "CP03", suffix: "009E", name: "Unemployment Rate", description: "Number unemployed as a percent of the workforce", unit: "%"),
            (source: CensusClient.Sources.ACS, prefix: "CP03", suffix: "025E", name: "Average Travel Time To Work", description: "Average Travel Time To Work for workers 16 and over (Minutes)", unit: " minutes"),
            (source: CensusClient.Sources.ACS, prefix: "CP02", suffix: "001E", name: "Total Households", description: "Total Number of Households (people who occupy a housing unit)", unit: ""),
            (source: CensusClient.Sources.ACS, prefix: "CP02", suffix: "092E", name: "Foreign Born", description: "People who were not born in the USA (%)", unit: "%"),
            (source: CensusClient.Sources.ACS, prefix: "CP03", suffix: "099E", name: "No Health Insurance Coverage", description: "Civilian noninstitutionalized population with no health insurance coverage (%)", unit: "%"),
            (source: CensusClient.Sources.SAIPE, prefix: "SAEMHI_PT", suffix: "", name: "Median Household Income", description: "Median Household Income ($)", unit: "$"),
            (source: CensusClient.Sources.SAIPE, prefix: "SAEPOVRTALL_PT", suffix: "", name: "Poverty Rate", description: "People living in housholds with income below the poverty threshold (%)", unit: "%"),
            (source: CensusClient.Sources.ACS, prefix: "CP02", suffix: "066E", name: "High school graduate or higher", description: "Population 25 years and over who graduated high school or higher (%)", unit: "%"),
            (source: CensusClient.Sources.ACS, prefix: "CP02", suffix: "067E", name: "Bachelor's degree or higher", description: "Population 25 years and over with bachelors degree or higher (%)", unit: "%"),
            (source: CensusClient.Sources.ACS, prefix: "CP02", suffix: "039E", name: "Fertility (births in past 12 months)", description: "Number of women 15 to 50 years old who had a birth in the past 12 months (per 1000)", unit: " births per 1000 women 15-50")
        ]
        
        context!.performAndWait ({
            for fact in facts {
                var vars = ""
                if fact.source == CensusClient.Sources.ACS {
                    vars = self.varString(prefix: fact.prefix, years: CensusClient.Years, suffix: fact.suffix)
                } else {
                    vars = fact.prefix
                }
                
                // Create the Core Data CensusFact instance
                let _ = CensusFact(sourceId: fact.source, variableName: vars, name: fact.name, description: fact.description, unit: fact.unit, context: self.context!)
            }
            
            self.stack.save()
        })
    }
    
    func retrieveGeographies(completionHandlerForRetrieveData: @escaping (_  success: Bool, _ error: CensusClient.CensusClientError?) -> Void) {
        
        // Create a simple fetchrequest to get all geographies
        let fr: NSFetchRequest<Geography> = Geography.fetchRequest()
        
        var fetchedGeos: [Geography]?
        context!.performAndWait ({
            do {
                fetchedGeos = try self.context!.fetch(fr)
            } catch let error {
                completionHandlerForRetrieveData(false, error as? CensusClient.CensusClientError)
            }
        })
        
        if let geos = fetchedGeos {
            //  print("There are \(geos.count) geographies in the database")
            if geos.count == 0 {
                print("Retrieving geographies")
                CensusClient.sharedInstance().getGeography(geography: "state:*", time: "2015", context: context!) {(results, error) in
                    if let _ = results {
                        CensusClient.sharedInstance().getGeography(geography: "us:*", time: "2015", context: self.context!) {(results, error) in
                            if let _ = results {
                                self.context!.perform {
                                    self.stack.save()
                                }
                                self.gotGeographies = true
                                let notification = Notification(name: Notification.Name(rawValue: NotificationNames.GotGeographies))
                                NotificationCenter.default.post(notification)
                            } else {
                                completionHandlerForRetrieveData(false, error)
                            }
                            completionHandlerForRetrieveData(true, nil)
                        }
                    } else {
                        completionHandlerForRetrieveData(false, error)
                    }
                }
            } else {
                gotGeographies = true
                completionHandlerForRetrieveData(true, nil)
            }
        }
    }

    
    func retrieveAllFactValues(completionHandlerForRetrieveData: @escaping (_ success: Bool, _ error: CensusClient.CensusClientError?) -> Void) {
    
        stack.performBackgroundBatchOperation { (workerContext) in
            let allFacts = self.getAllFacts()
            for fact in allFacts {
                self.retrieveData(fact: fact) { (success, error) in
                    if success {
                        completionHandlerForRetrieveData(true, nil)
                        self.gotCensusValues = true
                        let notification = Notification(name: Notification.Name(rawValue: NotificationNames.GotCensusValues))
                        NotificationCenter.default.post(notification)
                    } else {
                        completionHandlerForRetrieveData(false, error)
                    }
                }
            }
        }
    }
    
    private func varString(prefix: String, years: [String], suffix: String) -> String {
        var result = ""
        for year in years {
            if result != "" {
                result = result + ","
            }
            result = result + prefix + "_" + year + "_" + suffix
        }
        return result
    }
    
    private func deleteAllFacts() {
        // Create a simple fetchrequest to get all facts (no sorting needed)
        let fr: NSFetchRequest<CensusFact> = CensusFact.fetchRequest()
        
        var fetchedFacts: [CensusFact]?
        context!.performAndWait ({
            do {
                fetchedFacts = try self.context!.fetch(fr)
                for fact in fetchedFacts! {
                    self.context!.delete(fact)
                }
            } catch let error {
                print("Error: \(error.localizedDescription)")
            }
        })
    }
    
    func deleteAllCensusValues() {
        // Create a simple fetchrequest to get all census values (no sorting needed)
        let fr: NSFetchRequest<CensusValue> = CensusValue.fetchRequest()
        
        var fetchedValues: [CensusValue]?
        context!.performAndWait ({
            do {
                fetchedValues = try self.context!.fetch(fr)
                for value in fetchedValues! {
                    self.context!.delete(value)
                }
            } catch let error {
                print("Error: \(error.localizedDescription)")
            }
            self.gotCensusValues = false
        })
    }
    
    func countCensusValues() -> Int {
        // Create a simple fetchrequest to get all census values (no sorting needed)
        let fr: NSFetchRequest<CensusValue> = CensusValue.fetchRequest()
        
        var fetchedValues: [CensusValue]?
        context!.performAndWait ({
            do {
                fetchedValues = try self.context!.fetch(fr)
            } catch let error {
                print("Error: \(error.localizedDescription)")
            }
        })
    return fetchedValues!.count
    }
        
    private func deleteAllGeographies() {
        // Create a simple fetchrequest to get all geographies (no sorting needed)
        let fr: NSFetchRequest<Geography> = Geography.fetchRequest()
        
        var fetchedGeographies: [Geography]?
        context!.performAndWait ({
            do {
                fetchedGeographies = try self.context!.fetch(fr)
                for geography in fetchedGeographies! {
                    self.context!.delete(geography)
                }
            } catch let error {
                print("Error: \(error.localizedDescription)")
            }
        })
    }
    
    func getAllFacts() -> [CensusFact] {
        // Create a simple fetchrequest to get all facts not in groups
        let fr: NSFetchRequest<CensusFact> = CensusFact.fetchRequest()
        
        //fr.predicate = NSPredicate(format: "isInGroup == nil")
        let sortDescriptor1 = NSSortDescriptor(key: "factName", ascending: true)
        let sortDescriptors = [sortDescriptor1]
        fr.sortDescriptors = sortDescriptors
        
        var fetchedFacts = [CensusFact]()
        context!.performAndWait ({
            do {
                fetchedFacts = try self.context!.fetch(fr)
            } catch let error {
                print("Error: \(error.localizedDescription)")
            }
        })
        return fetchedFacts
    }
    
    
    func retrieveData(fact: CensusFact, completionHandlerForRetrieveData: @escaping (_ success: Bool, _ error: CensusClient.CensusClientError?) -> Void) {
        
        print("Retrieving data for \(fact.factName!)...")
        
        if !fact.hasData() {
            // We don't have the data in the local DB yet, so get the data from the API
            if fact.sourceId == CensusClient.Sources.SAIPE {
                CensusClient.sharedInstance().getSAIPEValues(fact: fact, geography: "state:*", time: "from+1995+to+2015", context: context!) {(results, error) in
                    if let _ = results {
                        CensusClient.sharedInstance().getSAIPEValues(fact: fact, geography: "us:*", time: "from+1995+to+2015", context: self.context!) {(results, error) in
                            self.context!.perform {
                                self.stack.save()
                            }
                            completionHandlerForRetrieveData(true, nil)
                        }
                    } else {
                        completionHandlerForRetrieveData(false, error)
                    }
                }
            } else {
                CensusClient.sharedInstance().getACSValues(fact: fact, geography: "state:*", context: context!) {(results, error) in
                    if let _ = results {
                        CensusClient.sharedInstance().getACSValues(fact: fact, geography: "us:*", context: self.context!) {(results, error) in
                            self.context!.perform {
                                self.stack.save()
                            }
                        }
                    } else {
                        completionHandlerForRetrieveData(false, error)
                    }
                }
            }
        } else {
            completionHandlerForRetrieveData(true, nil)
        }
    }
/*
    func getData(fact: CensusFact, geography: Geography, completionHandlerForGetData: @escaping (_ result: [CensusValue]?, _ error: CensusClient.CensusClientError?) -> Void) {
        
        print("Getting data for \(fact.factName!)...")
        
        if !fact.hasData() {
            // We don't have the data in the local DB yet, so get the data from the API
            if fact.sourceId == CensusClient.Sources.SAIPE {
                CensusClient.sharedInstance().getSAIPEValues(fact: fact, geography: "state:*", time: "from+1995+to+2015", context: context!) {(results, error) in
                    if let _ = results {
                        //     print(results)
                        CensusClient.sharedInstance().getSAIPEValues(fact: fact, geography: "us:*", time: "from+1995+to+2015", context: self.context!) {(results, error) in
                            self.context!.perform {
                                self.stack.save()
                            }
                        }
                        self.getDataFromDB(forFact: fact, geography: geography) {(results, error) in
                            completionHandlerForGetData(results, error)
                        }
                    }
                }
            } else {
                CensusClient.sharedInstance().getACSValues(fact: fact, geography: "state:*", context: context!) {(results, error) in
                    if let _ = results {
                        //     print(results)
                        CensusClient.sharedInstance().getACSValues(fact: fact, geography: "us:*", context: self.context!) {(results, error) in
                            self.context!.perform {
                                self.stack.save()
                            }
                        }
                        self.getDataFromDB(forFact: fact, geography: geography) {(results, error) in
                            completionHandlerForGetData(results, error)
                        }
                    }
                }
            }
        } else {
            // We have the data in the local DB
            self.getDataFromDB(forFact: fact, geography: geography) {(results, error) in
                completionHandlerForGetData(results, error)
            }
        }
    }
 
 */

    
    func getDataFromDB(forFact: CensusFact, geography: Geography, completionHandlerForGetData: @escaping (_ results: [CensusValue]?, _ error: CensusClient.CensusClientError?) -> Void) {
        let fr: NSFetchRequest<CensusValue> = CensusValue.fetchRequest()
        
        fr.predicate = NSPredicate(format: "hasDescription.variableName == %@ AND appliesToGeography.name == %@", forFact.variableName!, geography.name!)
        
        let sortDescriptor1 = NSSortDescriptor(key: "year", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "hasDescription.factName", ascending: true)
        let sortDescriptors = [sortDescriptor1, sortDescriptor2]
        fr.sortDescriptors = sortDescriptors
        
        //print("Getting data for variable \(forFact.variableName!) and geo \(geography.name!)")
        
        var fetchedValues: [CensusValue]?
        context!.performAndWait ({
            do {
                fetchedValues = try self.context!.fetch(fr)
            } catch let error {
                completionHandlerForGetData(nil, error as? CensusClient.CensusClientError)
            }
            if let values = fetchedValues {
               // print("There are \(values.count) values in the database")
                completionHandlerForGetData(values, nil)
            }
        })
    }
    
    func getSelectedGeographies(completionHandlerForGetGeographies: @escaping (_ results: [Geography]?, _ error: CensusClient.CensusClientError?) -> Void) {
        let fr: NSFetchRequest<Geography> = Geography.fetchRequest()
        
        fr.predicate = NSPredicate(format: "isSelected == %@", true as CVarArg)
        
        var fetchedGeographies: [Geography]?
        context!.performAndWait ({
            do {
                fetchedGeographies = try self.context!.fetch(fr)
            } catch let error {
                completionHandlerForGetGeographies(nil, error as? CensusClient.CensusClientError)
            }
            if let geographies = fetchedGeographies {
               // print("There are \(geographies.count) selected geographies in the database")
                completionHandlerForGetGeographies(geographies, nil)
            }
        })
    }
    
    func selectAllGeographies(_ val: Bool, completionHandlerForGetGeographies: @escaping (_ success: Bool, _ error: CensusClient.CensusClientError?) -> Void) {
        let fr: NSFetchRequest<Geography> = Geography.fetchRequest()
        
        fr.predicate = NSPredicate(format: "isSelected == %@", !val as CVarArg)
        
        var fetchedGeographies: [Geography]?
        context!.performAndWait ({
            do {
                fetchedGeographies = try self.context!.fetch(fr)
            } catch let error {
                completionHandlerForGetGeographies(false, error as? CensusClient.CensusClientError)
            }
            if let geographies = fetchedGeographies {
                for geo in geographies {
                    geo.isSelected = val
                }
                self.context!.performAndWait {
                    self.stack.save()
                }
                completionHandlerForGetGeographies(true, nil)
            }
        })
    }
    
    
    
    // MARK: Shared Instance

    class func sharedInstance() -> CensusDataSource {
        struct Singleton {
            static var sharedInstance = CensusDataSource()
        }
        return Singleton.sharedInstance
    }

}
