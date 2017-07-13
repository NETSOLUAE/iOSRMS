//
//  ExSlideMenuController.swift
//  RMS
//
//  Created by Mac Mini on 7/5/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import UIKit

class ExSlideMenuController : SlideMenuController {
    
    override func isTagetViewController() -> Bool {
        if let vc = UIApplication.topViewController() {
            if vc is HomeController{
                return true
            }
        }
        return false
    }
    
    override func track(_ trackAction: TrackAction) {
        switch trackAction {
  
        case .leftTapOpen: break
        case .leftTapClose: break
        case .leftFlickOpen: break
        case .leftFlickClose: break
        case .rightTapOpen: break
        case .rightTapClose: break
        case .rightFlickOpen: break
        case .rightFlickClose: break

        }
    }
}

