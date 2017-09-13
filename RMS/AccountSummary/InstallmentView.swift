//
//  InstallmentView.swift
//  RMS
//
//  Created by Mac Mini on 8/24/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import UIKit

class InstallmentView: UITableViewCell {
    
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var regDate: UILabel!
    @IBOutlet weak var amount: UILabel!
    
    open class func height() -> CGFloat {
        return 44
    }
}
