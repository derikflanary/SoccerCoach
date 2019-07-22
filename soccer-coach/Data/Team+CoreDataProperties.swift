//
//  Team+CoreDataProperties.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/21/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//
//

import Foundation
import CoreData

extension Team {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Team> {
        return NSFetchRequest<Team>(entityName: "Team")
    }

    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var players: Set<SoccerPlayer>

}

// MARK: Generated accessors for players
extension Team {

    @objc(addPlayersObject:)
    @NSManaged public func addToPlayers(_ value: SoccerPlayer)

    @objc(removePlayersObject:)
    @NSManaged public func removeFromPlayers(_ value: SoccerPlayer)

    @objc(addPlayers:)
    @NSManaged public func addToPlayers(_ values: NSSet)

    @objc(removePlayers:)
    @NSManaged public func removeFromPlayers(_ values: NSSet)

}
