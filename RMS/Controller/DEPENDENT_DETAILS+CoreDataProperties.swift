//
//  DEPENDENT_DETAILS+CoreDataProperties.swift
//  RMS
//
//  Created by Mac Mini on 8/24/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import Foundation
import CoreData


extension DEPENDENT_DETAILS {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DEPENDENT_DETAILS> {
        return NSFetchRequest<DEPENDENT_DETAILS>(entityName: "DEPENDENT_DETAILS")
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
    @NSManaged public var staff: STAFF_DETAILS?

}
