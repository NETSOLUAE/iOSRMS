//
//  PolicyGroup.swift
//  RMS
//
//  Created by Mac Mini on 8/22/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import Foundation
import UIKit

class PolicyGroup: UITableViewHeaderFooterView {
    
    @IBOutlet weak var name: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.backgroundColor = .white
    }
}
