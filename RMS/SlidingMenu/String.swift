//
//  String.swift
//  RMS
//
//  Created by Mac Mini on 7/5/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import Foundation
import UIKit

extension String {
    static func className(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
    
    func substring(_ from: Int) -> String {
        return self.substring(from: self.characters.index(self.startIndex, offsetBy: from))
    }
    
    var length: Int {
        return self.characters.count
    }
    
    var htmlToAttributedString: NSAttributedString? {
        
        guard
            let d = data(using: String.Encoding.utf8, allowLossyConversion: true)
            else {
                return nil
        }
        
        do {
            let str = try NSAttributedString(data: d,
                                             options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                                             documentAttributes: nil)
            return str
        } catch let error as NSError {
            print(error.localizedDescription)
            return  nil
        }
    }
}
