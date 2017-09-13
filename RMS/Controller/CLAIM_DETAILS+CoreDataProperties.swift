//
//  CLAIM_DETAILS+CoreDataProperties.swift
//  RMS
//
//  Created by Mac Mini on 8/24/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import Foundation
import CoreData


extension CLAIM_DETAILS {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CLAIM_DETAILS> {
        return NSFetchRequest<CLAIM_DETAILS>(entityName: "CLAIM_DETAILS")
    }

    @NSManaged public var approved_amount: String?
    @NSManaged public var cheque_no: String?
    @NSManaged public var claim_no: String?
    @NSManaged public var claimed_mount: String?
    @NSManaged public var diagnosis: String?
    @NSManaged public var disallowance: String?
    @NSManaged public var excess: String?
    @NSManaged public var member_name: String?
    @NSManaged public var member_type: String?
    @NSManaged public var mode_of_payment: String?
    @NSManaged public var policy_no: String?
    @NSManaged public var reg_date: String?
    @NSManaged public var remarks: String?
    @NSManaged public var settled_amount: String?
    @NSManaged public var settled_amount_ro: String?
    @NSManaged public var staff_name: String?
    @NSManaged public var status: String?
    @NSManaged public var treatment_date: String?

}
