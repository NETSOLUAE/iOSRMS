//
//  PagerTabStripBehaviour.swift
//  RMS
//
//  Created by Mac Mini on 7/3/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import Foundation

public enum PagerTabStripBehaviour {
    
    case common(skipIntermediateViewControllers: Bool)
    case progressive(skipIntermediateViewControllers: Bool, elasticIndicatorLimit: Bool)
    
    public var skipIntermediateViewControllers: Bool {
        switch self {
        case .common(let skipIntermediateViewControllers):
            return skipIntermediateViewControllers
        case .progressive(let skipIntermediateViewControllers, _):
            return skipIntermediateViewControllers
        }
    }
    
    public var isProgressiveIndicator: Bool {
        switch self {
        case .common(_):
            return false
        case .progressive(_, _):
            return true
        }
    }
    
    public var isElasticIndicatorLimit: Bool {
        switch self {
        case .common(_):
            return false
        case .progressive(_, let elasticIndicatorLimit):
            return elasticIndicatorLimit
        }
    }
}

