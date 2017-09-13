//
//  ACCOUNT_SUMMARY+CoreDataProperties.swift
//  RMS
//
//  Created by Mac Mini on 8/24/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import Foundation
import CoreData


extension ACCOUNT_SUMMARY {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ACCOUNT_SUMMARY> {
        return NSFetchRequest<ACCOUNT_SUMMARY>(entityName: "ACCOUNT_SUMMARY")
    }

    @NSManaged public var endDate: String?
    @NSManaged public var insurer: String?
    @NSManaged public var nationalID: String?
    @NSManaged public var nextInstallmentAmount: Float
    @NSManaged public var outstandingAmount: Float
    @NSManaged public var policyNo: String?
    @NSManaged public var policyYear: String?
    @NSManaged public var staffID: String?
    @NSManaged public var startDate: String?
    @NSManaged public var status: String?
    @NSManaged public var totalPremium: String?
    @NSManaged public var vehicleNumber: String?
    @NSManaged public var installment: NSSet?

}

// MARK: Generated accessors for installment
extension ACCOUNT_SUMMARY {

    @objc(addInstallmentObject:)
    @NSManaged public func addToInstallment(_ value: POLICY_INSTALLMENT)

    @objc(removeInstallmentObject:)
    @NSManaged public func removeFromInstallment(_ value: POLICY_INSTALLMENT)

    @objc(addInstallment:)
    @NSManaged public func addToInstallment(_ values: NSSet)

    @objc(removeInstallment:)
    @NSManaged public func removeFromInstallment(_ values: NSSet)

}
