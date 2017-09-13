//
//  MASTER_DATA_SALARY+CoreDataProperties.swift
//  RMS
//
//  Created by Mac Mini on 8/24/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import Foundation
import CoreData


extension MASTER_DATA_SALARY {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MASTER_DATA_SALARY> {
        return NSFetchRequest<MASTER_DATA_SALARY>(entityName: "MASTER_DATA_SALARY")
    }

    @NSManaged public var changePin: String?
    @NSManaged public var clientID: String?
    @NSManaged public var nationalID: String?
    @NSManaged public var pin: String?
    @NSManaged public var staffID: String?

}
