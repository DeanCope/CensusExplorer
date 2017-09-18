//
//  Geography+CoreDataProperties.swift
//  CensusAPI
//
//  Created by Dean Copeland on 6/24/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import Foundation
import CoreData


extension Geography {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Geography> {
        return NSFetchRequest<Geography>(entityName: "Geography")
    }

    @NSManaged public var fipsCode: String?
    @NSManaged public var level: String?
    @NSManaged public var name: String?
    @NSManaged public var isSelected: Bool
    @NSManaged public var hasCensusValues: NSSet?

}

// MARK: Generated accessors for hasCensusValues
extension Geography {

    @objc(addHasCensusValuesObject:)
    @NSManaged public func addToHasCensusValues(_ value: CensusValue)

    @objc(removeHasCensusValuesObject:)
    @NSManaged public func removeFromHasCensusValues(_ value: CensusValue)

    @objc(addHasCensusValues:)
    @NSManaged public func addToHasCensusValues(_ values: NSSet)

    @objc(removeHasCensusValues:)
    @NSManaged public func removeFromHasCensusValues(_ values: NSSet)

}
