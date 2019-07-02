//
//  ReusableView.swift
//  soccer-coach
//
//  Created by Derik Flanary on 6/17/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import Foundation
import UIKit

protocol ReusableView: class {}

extension ReusableView where Self: UIView {
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    static func nib() -> UINib {
        return UINib(nibName: reuseIdentifier, bundle: Bundle.main)
    }
    
}
