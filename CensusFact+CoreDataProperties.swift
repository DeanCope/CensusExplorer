//
//  CensusFact+CoreDataProperties.swift
//  CensusAPI
//
//  Created by Dean Copeland on 10/2/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//
//

import Foundation
import CoreData


extension CensusFact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CensusFact> {
        return NSFetchRequest<CensusFact>(entityName: "CensusFact")
    }

    @NSManaged public var factDescription: String?
    @NSManaged public var factName: String?
    @NSManaged public var groupName: String?
    @NSManaged public var isSelected: Bool
    @NSManaged public var sourceId: String?
    @NSManaged public var unit: String?
    @NSManaged public var variableName: String?
    @NSManaged public var describes: NSSet?

}

// MARK: Generated accessors for describes
extension CensusFact {

    @objc(addDescribesObject:)
    @NSManaged public func addToDescribes(_ value: CensusValue)

    @objc(removeDescribesObject:)
    @NSManaged public func removeFromDescribes(_ value: CensusValue)

    @objc(addDescribes:)
    @NSManaged public func addToDescribes(_ values: NSSet)

    @objc(removeDescribes:)
    @NSManaged public func removeFromDescribes(_ values: NSSet)

}
