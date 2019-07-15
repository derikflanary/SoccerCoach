//
//  Shot.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/14/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import Foundation

struct Shot: TimeStampable {
    let onTarget: Bool
    let isGoal: Bool
    var timeStamp: Int
    var half: Int
}
