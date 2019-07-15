//
//  TimeStampable.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/14/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import Foundation

protocol TimeStampable {
    var timeStamp: Int { get set }
    var half: Int { get set }
}
