//
//  Position.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/26/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import Foundation

enum Position: Int, CaseIterable {
    case one = 1
    case two = 2
    case three, four, five, six, seven, eight, nine, ten, eleven
    
    var name: String {
        return "\(self.rawValue)"
    }
    
}
