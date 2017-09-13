//
//  MASTER_DATA_LINES+CoreDataProperties.swift
//  RMS
//
//  Created by Mac Mini on 8/24/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import Foundation
import CoreData


extension MASTER_DATA_LINES {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MASTER_DATA_LINES> {
        return NSFetchRequest<MASTER_DATA_LINES>(entityName: "MASTER_DATA_LINES")
    }

    @NSManaged public var staffID: String?
    @NSManaged public var pin: String?
    @NSManaged public var nationalID: String?
    @NSManaged public var clientID: String?
    @NSManaged public var changePin: String?

}
