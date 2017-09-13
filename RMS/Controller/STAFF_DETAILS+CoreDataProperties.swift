//
//  STAFF_DETAILS+CoreDataProperties.swift
//  RMS
//
//  Created by Mac Mini on 8/24/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import Foundation
import CoreData


extension STAFF_DETAILS {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<STAFF_DETAILS> {
        return NSFetchRequest<STAFF_DETAILS>(entityName: "STAFF_DETAILS")
    }

    @NSManaged public var client_id: String?
    @NSManaged public var dender: String?
    @NSManaged public var effective_date: String?
    @NSManaged public var email: String?
    @NSManaged public var member_id: String?
    @NSManaged public var member_name: String?
    @NSManaged public var nationality: String?
    @NSManaged public var phone: String?
    @NSManaged public var policy_ref: String?
    @NSManaged public var relationship: String?
    @NSManaged public var staff_id: String?
    @NSManaged public var dependent: NSSet?

}

// MARK: Generated accessors for dependent
extension STAFF_DETAILS {

    @objc(addDependentObject:)
    @NSManaged public func addToDependent(_ value: DEPENDENT_DETAILS)

    @objc(removeDependentObject:)
    @NSManaged public func removeFromDependent(_ value: DEPENDENT_DETAILS)

    @objc(addDependent:)
    @NSManaged public func addToDependent(_ values: NSSet)

    @objc(removeDependent:)
    @NSManaged public func removeFromDependent(_ values: NSSet)

}
