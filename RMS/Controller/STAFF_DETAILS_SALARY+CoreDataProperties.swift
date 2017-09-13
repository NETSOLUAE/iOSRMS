//
//  STAFF_DETAILS_SALARY+CoreDataProperties.swift
//  RMS
//
//  Created by Mac Mini on 8/24/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import Foundation
import CoreData


extension STAFF_DETAILS_SALARY {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<STAFF_DETAILS_SALARY> {
        return NSFetchRequest<STAFF_DETAILS_SALARY>(entityName: "STAFF_DETAILS_SALARY")
    }

    @NSManaged public var clientID: String?
    @NSManaged public var nationalID: String?
    @NSManaged public var staffID: String?
    @NSManaged public var staffName: String?

}
