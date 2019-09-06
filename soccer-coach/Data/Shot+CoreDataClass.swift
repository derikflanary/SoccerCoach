//
//  Shot+CoreDataClass.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/22/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//
//

import Foundation
import CoreData


public class Shot: NSManagedObject {

    func minuteString(halfLength: Int) -> String {
        return "\(Int(timeStamp).minute())"
    }
    
}

struct TemporaryShot {
    let player: SoccerPlayer
    let onTarget: Bool
    let isGoal: Bool
}
