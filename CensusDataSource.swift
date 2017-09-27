//
//  CensusDataSource.swift
//  CensusAPI
//
//  Created by Dean Copeland on 6/16/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import Foundation
import CoreData

class CensusDataSource: NSObject {
    
    // source: https://thatthinginswift.com/singletons/
    static let sharedInstance = CensusDataSource()
    
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

        let allFacts = getAllFacts()
        
        guard allFacts.count == 0 else {
            return
        }
        
        // Stage the facts data into an array of tuples
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
        
        // Convert the array of tuples into CoreData CensusFact objects
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
        
        // This method checks if the geography data is in the local Core Data DB.  If it's not there (e.g. first time app use) then it requests the data from the Census server and puts it into Core Data.
        
        // First, look in Core Data...
        // Create a simple fetchrequest to get all geographies from Core Data
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
            if geos.count == 0 {
                // The core data request succeeded, but returned an empty list of geos.  This is the normal case for first time usage, or if the user has requested a data reload.  So, we need to get the data from the Census server...
                
                // Try getting the states first.
                CensusClient.sharedInstance.getGeography(geography: "state:*", time: "2015", context: context!) {(results, error) in
                    if let _ = results {
                        // States succeeded, so get eh row for the whole coutry...
                        CensusClient.sharedInstance.getGeography(geography: "us:*", time: "2015", context: self.context!) {(results, error) in
                            if let _ = results {
                                self.context!.perform {
                                    self.stack.save()
                                }
                                self.gotGeographies = true
                                self.sendGotGeographiesNotification()
                                completionHandlerForRetrieveData(true, nil)
                            } else {
                                self.sendGetGeographiesErrorNotification(error: error)
                                completionHandlerForRetrieveData(false, error)
                            }
                        }
                    } else {
                        self.sendGetGeographiesErrorNotification(error: error)
                        completionHandlerForRetrieveData(false, error)
                    }
                }
            } else {
                gotGeographies = true
                // In this case, we already have the geographies locally, so we don;t need to send a Notification
                completionHandlerForRetrieveData(true, nil)
            }
        }
    }
    
    func sendGetGeographiesErrorNotification(error: CensusClient.CensusClientError?) {
        var userInfo: [AnyHashable : Any]? = nil
        if let error = error {
            userInfo = [NotificationNames.GetGeographiesError: error]
        }
        let notification = Notification(name: Notification.Name(rawValue: NotificationNames.GetGeographiesError), object: nil, userInfo:userInfo)
        NotificationCenter.default.post(notification)
    }
    
    func sendGetCensusValuesProgressNotification(message: String) {
        var userInfo: [AnyHashable : Any]? = nil
        userInfo = [NotificationNames.GetCensusValuesProgressMessage: message]
        let notification = Notification(name: Notification.Name(rawValue: NotificationNames.GetCensusValuesProgress), object: nil, userInfo:userInfo)
        NotificationCenter.default.post(notification)
    }
    
    func sendGotGeographiesNotification() {
        let notification = Notification(name: Notification.Name(rawValue: NotificationNames.GotGeographies), object: nil, userInfo: nil)
        NotificationCenter.default.post(notification)
    }

    
    func retrieveAllCensusValues(completionHandlerForRetrieveData: @escaping (_ success: Bool, _ error: CensusClient.CensusClientError?) -> Void) {
        
        // Source for use of GroupDispatch: https://www.raywenderlich.com/148515/grand-central-dispatch-tutorial-swift-3-part-2
        
        var storedError: CensusClient.CensusClientError?
        let group = DispatchGroup()
    
        stack.performBackgroundBatchOperation { (workerContext) in
            let allFacts = self.getAllFacts()
            for fact in allFacts {
                group.enter()
                self.retrieveData(fact: fact) { (success, error) in
                    if error != nil {
                        storedError = error
                    }
                    group.leave()
                    if success {
                        self.sendGetCensusValuesProgressNotification(message: "Got \(fact.factName!).")
                        completionHandlerForRetrieveData(true, nil)
                    } else {
                        completionHandlerForRetrieveData(false, error)
                    }
                }
            }
            group.notify(queue: DispatchQueue.main) {
                self.sendGetCensusValuesCompletionNotification(error: storedError)
                self.gotCensusValues = true
            }
        }
    }
    
    func sendGetCensusValuesCompletionNotification(error: CensusClient.CensusClientError?) {
        var notification: Notification
        var userInfo: [AnyHashable : Any]? = nil
        if let error = error {
            userInfo = [NotificationNames.GetCensusValuesError: error]
            notification = Notification(name: Notification.Name(rawValue: NotificationNames.GetCensusValuesError), object: nil, userInfo:userInfo)
        } else {
            notification = Notification(name: Notification.Name(rawValue: NotificationNames.GotCensusValues), object: nil, userInfo:userInfo)
        }
        
        NotificationCenter.default.post(notification)
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
   /*
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
 */
    
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
        
    func deleteAllGeographies() {
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

    func getAllGeographies() -> [Geography]? {
        // Create a simple fetchrequest to get all geographies (no sorting needed)
        let fr: NSFetchRequest<Geography> = Geography.fetchRequest()
        
        var fetchedGeographies: [Geography]?
        context!.performAndWait ({
            do {
                fetchedGeographies = try self.context!.fetch(fr)
            } catch let error {
                print("Error: \(error.localizedDescription)")
            }
        })
        return fetchedGeographies
    }
    
    func getAllCensusValues() -> [CensusValue]? {
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
        return fetchedValues
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
        
        if !fact.hasData() {
            // We don't have the data in the local DB yet, so get the data from the API
            if fact.sourceId == CensusClient.Sources.SAIPE {
                CensusClient.sharedInstance.getSAIPEValues(fact: fact, geography: "state:*", time: "from+1995+to+2015", context: context!) {(results, error) in
                    if let _ = results {
                        CensusClient.sharedInstance.getSAIPEValues(fact: fact, geography: "us:*", time: "from+1995+to+2015", context: self.context!) {(results, error) in
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
                CensusClient.sharedInstance.getACSValues(fact: fact, geography: "state:*", context: context!) {(results, error) in
                    if let _ = results {
                        CensusClient.sharedInstance.getACSValues(fact: fact, geography: "us:*", context: self.context!) {(results, error) in
                            self.context!.perform {
                                self.stack.save()
                            }
                            completionHandlerForRetrieveData(true, nil)
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
    
    func getDataFromDB(forFact: CensusFact, geography: Geography, completionHandlerForGetData: @escaping (_ results: [CensusValue]?, _ error: CensusClient.CensusClientError?) -> Void) {
        let fr: NSFetchRequest<CensusValue> = CensusValue.fetchRequest()
        
        fr.predicate = NSPredicate(format: "hasDescription.variableName == %@ AND appliesToGeography.name == %@", forFact.variableName!, geography.name!)
        
        let sortDescriptor1 = NSSortDescriptor(key: "year", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "hasDescription.factName", ascending: true)
        let sortDescriptors = [sortDescriptor1, sortDescriptor2]
        fr.sortDescriptors = sortDescriptors
        
        var fetchedValues: [CensusValue]?
        context!.performAndWait ({
            do {
                fetchedValues = try self.context!.fetch(fr)
            } catch let error {
                completionHandlerForGetData(nil, error as? CensusClient.CensusClientError)
            }
            if let values = fetchedValues {
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
}
