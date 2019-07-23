//
//  PlayingTime+CoreDataProperties.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/22/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//
//

import Foundation
import CoreData


extension PlayingTime {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlayingTime> {
        return NSFetchRequest<PlayingTime>(entityName: "PlayingTime")
    }

    @NSManaged public var length: Double
    @NSManaged public var half: Int64
    @NSManaged public var player: SoccerPlayer?
    @NSManaged public var shots: NSSet?
    @NSManaged public var assists: NSSet?
    @NSManaged public var fouls: NSSet?
    @NSManaged public var cards: NSSet?
    @NSManaged public var homeMatch: Match?
    @NSManaged public var awayMatch: Match?

}

// MARK: Generated accessors for shots
extension PlayingTime {

    @objc(addShotsObject:)
    @NSManaged public func addToShots(_ value: Shot)

    @objc(removeShotsObject:)
    @NSManaged public func removeFromShots(_ value: Shot)

    @objc(addShots:)
    @NSManaged public func addToShots(_ values: NSSet)

    @objc(removeShots:)
    @NSManaged public func removeFromShots(_ values: NSSet)

}

// MARK: Generated accessors for assists
extension PlayingTime {

    @objc(addAssistsObject:)
    @NSManaged public func addToAssists(_ value: Assist)

    @objc(removeAssistsObject:)
    @NSManaged public func removeFromAssists(_ value: Assist)

    @objc(addAssists:)
    @NSManaged public func addToAssists(_ values: NSSet)

    @objc(removeAssists:)
    @NSManaged public func removeFromAssists(_ values: NSSet)

}

// MARK: Generated accessors for fouls
extension PlayingTime {

    @objc(addFoulsObject:)
    @NSManaged public func addToFouls(_ value: Foul)

    @objc(removeFoulsObject:)
    @NSManaged public func removeFromFouls(_ value: Foul)

    @objc(addFouls:)
    @NSManaged public func addToFouls(_ values: NSSet)

    @objc(removeFouls:)
    @NSManaged public func removeFromFouls(_ values: NSSet)

}

// MARK: Generated accessors for cards
extension PlayingTime {

    @objc(addCardsObject:)
    @NSManaged public func addToCards(_ value: Card)

    @objc(removeCardsObject:)
    @NSManaged public func removeFromCards(_ value: Card)

    @objc(addCards:)
    @NSManaged public func addToCards(_ values: NSSet)

    @objc(removeCards:)
    @NSManaged public func removeFromCards(_ values: NSSet)

}