//
//  SectionContactAr.swift
//  RMS
//
//  Created by Mac Mini on 8/26/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import Foundation

struct SectionContactAr {
    var branchAr: String!
    var addressAr: [AddressAr]!
    var expandedAr: Bool!
    
    init(branchAr: String, addressAr: [AddressAr], expandedAr: Bool) {
        self.branchAr = branchAr
        self.addressAr = addressAr
        self.expandedAr = expandedAr
    }
}

struct AddressAr {
    var branch_name_ar: String!
    var telephone_ar: String!
    var mobile_ar: String!
    var email_ar: String!
    var address_ar: NSMutableAttributedString!
    
    init(branch_name_ar: String, address_ar: NSMutableAttributedString, telephone_ar: String,  mobile_ar: String, email_ar: String) {
        self.branch_name_ar = branch_name_ar
        self.telephone_ar = telephone_ar
        self.mobile_ar = mobile_ar
        self.email_ar = email_ar
        self.address_ar = address_ar
    }
}
