//
//  AccountSummaryView.swift
//  RMS
//
//  Created by Mac Mini on 8/22/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import UIKit

class AccountSummaryView: UITableViewCell {
    
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var regDate: UILabel!
    @IBOutlet weak var vehicleNo: UILabel!
    
    open class func height() -> CGFloat {
        return 44
    }
}
