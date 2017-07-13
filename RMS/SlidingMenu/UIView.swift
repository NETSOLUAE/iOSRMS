//
//  UIView.swift
//  RMS
//
//  Created by Mac Mini on 7/5/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import UIKit

extension UIView {
    class func loadNib<T: UIView>(_ viewType: T.Type) -> T {
//        let className = String.className(viewType)
        return Bundle(for: viewType).loadNibNamed("ImageViewHeader", owner: nil, options: nil)!.first as! T
    }
    
    class func loadNib() -> Self {
        return loadNib(self)
    }
}
