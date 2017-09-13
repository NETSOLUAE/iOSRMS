//
//  STAFF_DETAILS_POLICY+CoreDataProperties.swift
//  RMS
//
//  Created by Mac Mini on 8/24/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import Foundation
import CoreData


extension STAFF_DETAILS_POLICY {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<STAFF_DETAILS_POLICY> {
        return NSFetchRequest<STAFF_DETAILS_POLICY>(entityName: "STAFF_DETAILS_POLICY")
    }

    @NSManaged public var endDate: String?
    @NSManaged public var nationalID: String?
    @NSManaged public var policyNo: String?
    @NSManaged public var staffID: String?
    @NSManaged public var startDate: String?

}
