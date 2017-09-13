//
//  PRE_APPROVALS+CoreDataProperties.swift
//  RMS
//
//  Created by Mac Mini on 8/24/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import Foundation
import CoreData


extension PRE_APPROVALS {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PRE_APPROVALS> {
        return NSFetchRequest<PRE_APPROVALS>(entityName: "PRE_APPROVALS")
    }

    @NSManaged public var diagnosis: String?
    @NSManaged public var entry_dt: String?
    @NSManaged public var hospital_name: String?
    @NSManaged public var memberid: String?
    @NSManaged public var patient_name: String?
    @NSManaged public var place_code: String?
    @NSManaged public var pol_ref: String?
    @NSManaged public var pre_approvaldt: String?
    @NSManaged public var pre_approvalno: String?
    @NSManaged public var remarks: String?
    @NSManaged public var staff_id: String?
    @NSManaged public var staff_name: String?
    @NSManaged public var status: String?

}
