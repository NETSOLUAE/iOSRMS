//
//  Constants.swift
//  RMS
//
//  Created by Mac Mini on 7/1/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import UIKit
import Foundation

class Constants {
    let limitLength = 12
    let BASE_URL = "http://netsolintl.net/rmsllc/api.php";
    let BASE_URL_SALARY = "http://netsolintl.net/salarydeduction/api.php";
    let BASE_URL_LINES = "http://netsolintl.net/rmslines/api.php";
    let deviceID = UIDevice.current.identifierForVendor!.uuidString
    let errorMessage = "Oops! Our server is busy. Can you retry later.";
    let mobileNumberErrorMessage = "Please Enter your Phone Number";
    let nationalIdErrorMessage = "Please Enter your National ID";
    
    let validMobileNumberError = "Please enter valid mobile number with country code"
    let validEmailErrorMessage = "Please enter valid email address"
    let allFieldsErrorMessage = "All fields are Mandatory"
    let passwordMismatchError = "Entered Password and Confirm Password does not match"
    let passwordLengthError = "Password should be more than 5 characters"
    
    let remainderLoading = "Submitting Your Remainder..."
    let feedbackLoading = "Submitting Your Enquiry / Feedback..."
    let registrationLoading = "Confirming Registration…"
    let commentsLoading = "Submitting Comments..."
    
    public func isValidMobileNumber(mobile: String) -> Bool {
        let replacedmobile = mobile.replacingOccurrences(of: " ", with: "")
        let countryCode = replacedmobile.substring(to: (replacedmobile.index((replacedmobile.startIndex), offsetBy: 3)))
        if (replacedmobile.length < 11) {
            return false
        } else if (countryCode == "968" || countryCode == "971") {
            return true
        } else {
            return false
        }
    }
}
