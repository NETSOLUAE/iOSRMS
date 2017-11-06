//
//  EB_POLICY_GROUP+CoreDataProperties.swift
//  RMS
//
//  Created by Mac Mini on 11/4/17.
//  Copyright © 2017 Netsol. All rights reserved.
//
//

import Foundation
import CoreData


extension EB_POLICY_GROUP {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EB_POLICY_GROUP> {
        return NSFetchRequest<EB_POLICY_GROUP>(entityName: "EB_POLICY_GROUP")
    }

    @NSManaged public var memberNameEb: String?
    @NSManaged public var memberTypeEb: String?
    @NSManaged public var relationshipTypeEb: String?

}
