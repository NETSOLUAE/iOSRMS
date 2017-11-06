//
//  ExpandableHeaderViewDelegeteAr.swift
//  RMS
//
//  Created by Mac Mini on 8/26/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import UIKit

protocol ExpandableHeaderViewDelegateAr {
    func toggleSectionAr(header: ExpandableHeaderViewAr, section: Int)
}

class ExpandableHeaderViewAr: UITableViewHeaderFooterView {
    var delegateAr: ExpandableHeaderViewDelegateAr?
    var sectionAr: Int!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectHeaderActionAr)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func selectHeaderActionAr(gestureRecognizer: UITapGestureRecognizer) {
        let cell = gestureRecognizer.view as! ExpandableHeaderViewAr
        delegateAr?.toggleSectionAr(header: self, section: cell.sectionAr)
    }
    
    func customInit(titleAr: String, sectionAr: Int, delegateAr: ExpandableHeaderViewDelegateAr) {
        self.textLabel?.text = titleAr
        self.sectionAr = sectionAr
        self.delegateAr = delegateAr
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textLabel?.textColor = UIColor.black
        self.textLabel?.textAlignment = NSTextAlignment.right
        self.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        contentView.backgroundColor = UIColor.white
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
