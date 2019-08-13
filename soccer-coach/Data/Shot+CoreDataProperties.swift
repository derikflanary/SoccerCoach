//
//  Shot+CoreDataProperties.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/22/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//
//

import Foundation
import CoreData


extension Shot {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Shot> {
        return NSFetchRequest<Shot>(entityName: "Shot")
    }

    @NSManaged public var onTarget: Bool
    @NSManaged public var isGoal: Bool
    @NSManaged public var half: Int64
    @NSManaged public var timeStamp: Int64
    @NSManaged public var rating: Int64
    @NSManaged public var playingTime: PlayingTime?
    @NSManaged public var shotDescription: String?
    @NSManaged public var assistee: SoccerPlayer?

}
