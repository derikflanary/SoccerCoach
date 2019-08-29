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
        let shotHalf = Half(rawValue: (Int(half))) ?? .first
        return "\(Int(timeStamp).minutes.minute(halfLength: halfLength, half: shotHalf))"
    }
    
}

struct TemporaryShot {
    let player: SoccerPlayer
    let onTarget: Bool
    let isGoal: Bool
}
