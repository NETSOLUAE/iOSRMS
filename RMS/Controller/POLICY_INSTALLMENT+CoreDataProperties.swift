//
//  POLICY_INSTALLMENT+CoreDataProperties.swift
//  RMS
//
//  Created by Mac Mini on 8/24/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import Foundation
import CoreData


extension POLICY_INSTALLMENT {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<POLICY_INSTALLMENT> {
        return NSFetchRequest<POLICY_INSTALLMENT>(entityName: "POLICY_INSTALLMENT")
    }

    @NSManaged public var amount: String?
    @NSManaged public var date: String?
    @NSManaged public var status: String?
    @NSManaged public var vehicleNumber: String?
    @NSManaged public var account: ACCOUNT_SUMMARY?

}
