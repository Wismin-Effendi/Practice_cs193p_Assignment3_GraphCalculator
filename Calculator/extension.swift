//
//  extension.swift
//  Calculator
//
//  Created by Wismin Effendi on 6/22/17.
//  Copyright © 2017 iShinobi. All rights reserved.
//

import UIKit

extension UIViewController {
    
    var contentViewController: UIViewController? {
        if let navVC = self as? UINavigationController {
            return navVC.visibleViewController
        } else {
            return self
        }
    }
}

extension CGPoint {
    mutating func offsetBy(dx: CGFloat, dy: CGFloat) {
        self.x += dx
        self.y += dy
    }
} 
