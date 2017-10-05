//
//  CoreDataStack.swift
//
//
//  Created by Fernando Rodríguez Romero on 21/02/16.
//  Copyright © 2016 udacity.com. All rights reserved.
//

import CoreData

// MARK: - CoreDataStack

struct CoreDataStack {
    
    // MARK: Properties
    
    private let model: NSManagedObjectModel
    internal let coordinator: NSPersistentStoreCoordinator
    private let modelURL: URL
    internal let dbURL: URL
    internal let persistingContext: NSManagedObjectContext
    internal let backgroundContext: NSManagedObjectContext
    let context: NSManagedObjectContext
    
    // MARK: Initializers
    
    init?(modelName: String) {
        
        // Assumes the model is in the main bundle
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            print("\(#function) Unable to find \(modelName)in the main bundle")
            return nil
        }
        self.modelURL = modelURL
        
        // Try to create the model from the URL
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            print("\(#function) unable to create a model from \(modelURL)")
            return nil
        }
        self.model = model
        
        // Create the store coordinator
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        // Create a persistingContext (private queue) and a child one (main queue)
        // create a context and connect it to the coordinator
        persistingContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        persistingContext.persistentStoreCoordinator = coordinator
        
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = persistingContext
        
        // Create a background context child of main context
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = context
        
        // Add a SQLite store located in the documents folder
        let fm = FileManager.default
        
        guard let docUrl = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("\(#function) Unable to reach the documents folder")
            return nil
        }
        
        self.dbURL = docUrl.appendingPathComponent("model.sqlite")
        
        // Options for migration
        let options = [NSInferMappingModelAutomaticallyOption: true,NSMigratePersistentStoresAutomaticallyOption: false]
        
        
        // If not compatible, destroy the old datastore by calling DropAllData
        
        if !store(storeURL: dbURL, isCompatibleWithModel: model) {
            print("\(#function) model is not compatible, so deleting the old DB...")
            do {
            try coordinator.destroyPersistentStore(at: dbURL, ofType: NSSQLiteStoreType , options: nil)
            } catch {
                print("\(#function) unable to delete incompatible store \(dbURL)")
            }
        }
        
        
        do {
            try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: options as [NSObject : AnyObject]?)
        } catch {
            print("\(#function) unable to add store at \(dbURL)")
        }
    }
    
    // MARK: Utils
    
    func addStoreCoordinator(_ storeType: String, configuration: String?, storeURL: URL, options : [NSObject:AnyObject]?) throws {
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL, options: nil)
    }
    
    // Source: http://www.informit.com/articles/article.aspx?p=2469048&seqNum=5
    func storeExistsAtPath(storeURL: URL) -> Bool {

            if FileManager.default.fileExists(atPath: storeURL.path) {
                return true
            }

        return false
    }
    
    // Source: http://www.informit.com/articles/article.aspx?p=2469048&seqNum=5
    func store(storeURL: URL, isCompatibleWithModel model:NSManagedObjectModel) -> Bool {
        
        if self.storeExistsAtPath(storeURL: storeURL) == false {
            return true // prevent migration of a store that does not exist
        }
        
        do {
            var _metadata:[String : Any]?
            _metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: storeURL, options: nil)
            if let metadata = _metadata {
                if model.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata) {
                    
               //     print("\(#function) The store is compatible with the current version of the model")
                    return true
                }
            } else {
                print("\(#function) FAILED to get metadata")
            }
        } catch {
            print("\(#function) ERROR getting metadata from \(storeURL) \(error)")
        }
        print("\(#function) The store is NOT compatible with the current version of the model")
        return false
    }
}

// MARK: - CoreDataStack (Removing Data)

internal extension CoreDataStack  {
    
    func dropAllData() throws {
        // delete all the objects in the db. This won't delete the files, it will
        // just leave empty tables.
        try coordinator.destroyPersistentStore(at: dbURL, ofType: NSSQLiteStoreType , options: nil)
        try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: nil)
    }
}

// MARK: - CoreDataStack (Batch Processing in the Background)

extension CoreDataStack {
    
    typealias Batch = (_ workerContext: NSManagedObjectContext) -> ()
    
    func performBackgroundBatchOperation(_ batch: @escaping Batch) {
        
        backgroundContext.perform() {
            
            batch(self.backgroundContext)
            
            // Save it to the parent context, so normal saving
            // can work
            do {
                try self.backgroundContext.save()
            } catch {
                fatalError("Error while saving backgroundContext: \(error)")
            }
        }
    }
}

// MARK: - CoreDataStack (Save Data)

extension CoreDataStack {

    func save() {
        // We call this synchronously, but it's a very fast
        // operation (it doesn't hit the disk). We need to know
        // when it ends so we can call the next save (on the persisting
        // context). This last one might take some time and is done
        // in a background queue
        context.performAndWait() {
            
            if self.context.hasChanges {
                do {
                    try self.context.save()
                } catch {
                    fatalError("Error while saving main context: \(error)")
                }
                
                // now we save in the background
                self.persistingContext.perform() {
                    do {
                        try self.persistingContext.save()
                    } catch {
                        fatalError("Error while saving persisting context: \(error)")
                    }
                }
            }
        }
    }
    
    func autoSave(_ delayInSeconds : Int) {
        
        if delayInSeconds > 0 {
            do {
                try self.context.save()
                //print("Autosaving")
            } catch {
                print("\(#function) Error while autosaving")
            }
            
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: time) {
                self.autoSave(delayInSeconds)
            }
        }
    }
}
