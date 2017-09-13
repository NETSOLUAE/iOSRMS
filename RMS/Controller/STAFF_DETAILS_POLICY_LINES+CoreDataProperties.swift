//
//  STAFF_DETAILS_POLICY_LINES+CoreDataProperties.swift
//  RMS
//
//  Created by Mac Mini on 8/24/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import Foundation
import CoreData


extension STAFF_DETAILS_POLICY_LINES {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<STAFF_DETAILS_POLICY_LINES> {
        return NSFetchRequest<STAFF_DETAILS_POLICY_LINES>(entityName: "STAFF_DETAILS_POLICY_LINES")
    }

    @NSManaged public var endDate: String?
    @NSManaged public var nationalID: String?
    @NSManaged public var policyNo: String?
    @NSManaged public var staffID: String?
    @NSManaged public var startDate: String?

}
