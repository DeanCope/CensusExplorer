//
//  CensusValue+CoreDataProperties.swift
//  CensusAPI
//
//  Created by Dean Copeland on 6/17/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import Foundation
import CoreData


extension CensusValue {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CensusValue> {
        return NSFetchRequest<CensusValue>(entityName: "CensusValue")
    }

    @NSManaged public var asOfDate: NSDate?
    @NSManaged public var value: Double
    @NSManaged public var year: Int16
    @NSManaged public var month: Int16
    @NSManaged public var dateLevel: String?
    @NSManaged public var appliesToGeography: Geography?
    @NSManaged public var hasDescription: CensusFact?

}
