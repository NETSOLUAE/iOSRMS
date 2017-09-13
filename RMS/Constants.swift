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
    let BASE_URL = "http://netsolintl.net/rmsllc/api.php";
    let BASE_URL_SALARY = "http://netsolintl.net/rmslines/api.php";
    let BASE_URL_LINES = "http://netsolintl.net/salarydeduction/api.php";
    let deviceID = UIDevice.current.identifierForVendor!.uuidString
    let errorMessage = "Oops! Our server is busy. Can you retry later.";
    let mobileNumberErrorMessage = "Please Enter your Phone Number";
    let nationalIdErrorMessage = "Please Enter your National ID";
}
