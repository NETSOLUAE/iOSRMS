//
//  BaseTableViewCell.swift
//  RMS
//
//  Created by Mac Mini on 7/5/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import UIKit

open class BaseTableViewCell : UITableViewCell {
    class var identifier: String { return String.className(self) }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    open override func awakeFromNib() {
    }
    
    open func setup() {
    }
    
    open class func height() -> CGFloat {
        return 48
    }
    
    open func setData(_ data: Any?, _ image: Any?) {
        self.backgroundColor = .white
        self.textLabel?.font = UIFont.systemFont(ofSize: 13)
        self.textLabel?.textColor = .black
        if let menuText = data as? String {
            self.textLabel?.text = menuText
        }
        if let images = image as? UIImage {
            self.imageView?.image = images
        }
    }
    
    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.alpha = 0.4
        } else {
            self.alpha = 1.0
        }
    }
    
    // ignore the default handling
    override open func setSelected(_ selected: Bool, animated: Bool) {
    }
    
}
