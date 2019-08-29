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
    
    func setCurrentLength(match: Match) {
        switch match.currentHalf {
        case .first:
            length = match.firstHalfTimeElapsed - startTime
        case .second:
            length = match.secondHalfTimeElapsed - startTime
        case .extra:
            length = match.extraTimeTimeElaspsed - startTime
        }
    }

}
