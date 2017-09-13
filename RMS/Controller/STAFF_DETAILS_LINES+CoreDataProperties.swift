//
//  STAFF_DETAILS_LINES+CoreDataProperties.swift
//  RMS
//
//  Created by Mac Mini on 8/24/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import Foundation
import CoreData


extension STAFF_DETAILS_LINES {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<STAFF_DETAILS_LINES> {
        return NSFetchRequest<STAFF_DETAILS_LINES>(entityName: "STAFF_DETAILS_LINES")
    }

    @NSManaged public var clientID: String?
    @NSManaged public var staffID: String?
    @NSManaged public var nationalID: String?
    @NSManaged public var staffName: String?

}
