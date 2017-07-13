//
//  IndicatorInfo.swift
//  RMS
//
//  Created by Mac Mini on 7/3/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import Foundation
import UIKit

public struct IndicatorInfo {
    
    public var title: String?
    public var image: UIImage?
    public var highlightedImage: UIImage?
    
    public init(title: String?) {
        self.title = title
    }
    
    public init(image: UIImage?, highlightedImage: UIImage? = nil) {
        self.image = image
        self.highlightedImage = highlightedImage
    }
    
    public init(title: String?, image: UIImage?, highlightedImage: UIImage? = nil) {
        self.title = title
        self.image = image
        self.highlightedImage = highlightedImage
    }
    
}

extension IndicatorInfo : ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        title = value
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        title = value
    }
    
    public init(unicodeScalarLiteral value: String) {
        title = value
    }
}

