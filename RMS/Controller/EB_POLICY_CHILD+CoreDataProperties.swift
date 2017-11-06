//
//  EB_POLICY_CHILD+CoreDataProperties.swift
//  RMS
//
//  Created by Mac Mini on 11/5/17.
//  Copyright © 2017 Netsol. All rights reserved.
//
//

import Foundation
import CoreData


extension EB_POLICY_CHILD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EB_POLICY_CHILD> {
        return NSFetchRequest<EB_POLICY_CHILD>(entityName: "EB_POLICY_CHILD")
    }

    @NSManaged public var startDateEb: String?
    @NSManaged public var memberIdEb: String?
    @NSManaged public var policyRefEb: String?
    @NSManaged public var endDateEb: String?
    @NSManaged public var companyNameEb: String?
    @NSManaged public var staffIdEb: String?

}
