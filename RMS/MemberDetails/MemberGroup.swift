//
//  MemberGroup.swift
//  RMS
//
//  Created by Mac Mini on 7/11/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import UIKit

class MemberGroup: UITableViewHeaderFooterView {
    
    @IBOutlet weak var name: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.backgroundColor = .white
    }
}
