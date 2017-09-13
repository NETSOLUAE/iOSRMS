//
//  ACCOUNT_SUMMARY_LINES+CoreDataProperties.swift
//  RMS
//
//  Created by Mac Mini on 8/24/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import Foundation
import CoreData


extension ACCOUNT_SUMMARY_LINES {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ACCOUNT_SUMMARY_LINES> {
        return NSFetchRequest<ACCOUNT_SUMMARY_LINES>(entityName: "ACCOUNT_SUMMARY_LINES")
    }

    @NSManaged public var vehicleNumber: String?
    @NSManaged public var totalPremium: String?
    @NSManaged public var status: String?
    @NSManaged public var startDate: String?
    @NSManaged public var staffID: String?
    @NSManaged public var policyYear: String?
    @NSManaged public var policyNo: String?
    @NSManaged public var outstandingAmount: Float
    @NSManaged public var nextInstallmentAmount: Float
    @NSManaged public var nationalID: String?
    @NSManaged public var insurer: String?
    @NSManaged public var endDate: String?

}
