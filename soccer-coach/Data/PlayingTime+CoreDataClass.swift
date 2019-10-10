//
//  PlayingTime+CoreDataClass.swift
//  soccer-coach
//
//  Created by Derik Flanary on 8/28/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//
//

import Foundation
import CoreData


public class PlayingTime: NSManagedObject {

    var isActive = false
    
    var position: Position {
        return Position(rawValue: Int(positionValue)) ?? .six
    }
    
    var length: Int {
        return Int(endTime - startTime)
    }

}
