//
//  MASTER_DATA+CoreDataProperties.swift
//  RMS
//
//  Created by Mac Mini on 8/24/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import Foundation
import CoreData


extension MASTER_DATA {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MASTER_DATA> {
        return NSFetchRequest<MASTER_DATA>(entityName: "MASTER_DATA")
    }

    @NSManaged public var changePin: String?
    @NSManaged public var clientID: String?
    @NSManaged public var mobileNumber: String?
    @NSManaged public var pin: String?
    @NSManaged public var staffID: String?

}
