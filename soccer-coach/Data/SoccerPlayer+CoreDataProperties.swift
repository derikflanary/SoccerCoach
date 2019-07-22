//
//  SoccerPlayer+CoreDataProperties.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/21/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//
//

import Foundation
import CoreData

extension SoccerPlayer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SoccerPlayer> {
        return NSFetchRequest<SoccerPlayer>(entityName: "SoccerPlayer")
    }

    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var isActive: Bool
    @NSManaged public var number: String?
    @NSManaged public var team: Team?

}
